extends Node2D

enum State {
	IDLE,
	CHASE,
	ATTACK,
	LAZER_BEAM
}

# Variables for the child nodes
@onready var cyclops_sprite = $cyclops_sprite
@onready var stomp_area2d = $Stomp_range
@onready var throw_rock_area2d = $throw_rock_range
@onready var lazer_beam_area2d = $lazer_beam_range
@onready var lazer_beam_timer = $lazer_beam_cooldown
@onready var health_bar = $RigidBody2D/HealthBar

# Initializing game-state variables (do not change!)
var player : CharacterBody2D = null
var current_state : State = State.IDLE
var is_attacking : bool = false
var lazer_beam_ready : bool = true
var in_stomp_range = false
var in_throw_rock_range = false
var in_lazer_beam_range = false

# Adjust these accordingly
var max_health : int = 400
var health : int = max_health
var attack : int = 80
var defense : int = 20
var chase_range: float = 500 # Switches from Idle to Chase
var attack_range: float = 35 # Switches from Chase to Attack
var speed: float = 85  # Cyclops's movement speed
var lazer_range = 60 # Range that Cyclops will use lazer
var charge_range = 150 # Range that Cyclops will use charge
var eruption_range = 200 # Range that Cyclops will use eruption

# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar.value = (float(health) / max_health) * 100
	player = get_parent().get_node("Player")
	if player:
		print("Player node found: ", player)
	else:
		print("Error: Player node not found")

	# Connect signals
	stomp_area2d.body_entered.connect(Callable(self, "_on_stomp_range_body_entered"))
	stomp_area2d.body_exited.connect(Callable(self, "_on_stomp_range_body_exited"))
	throw_rock_area2d.body_entered.connect(Callable(self, "_on_throw_rock_range_body_entered"))
	throw_rock_area2d.body_exited.connect(Callable(self, "_on_throw_rock_range_body_exited"))
	lazer_beam_area2d.body_entered.connect(Callable(self, "_on_lazer_beam_range_body_entered"))
	lazer_beam_area2d.body_exited.connect(Callable(self, "_on_lazer_beam_range_body_exited"))
	lazer_beam_timer.timeout.connect(Callable(self, "_on_lazer_beam_cooldown_timeout"))

func _process(delta):
	match current_state:
		State.IDLE:
			idle_state(delta)
		State.CHASE:
			chase_state(delta)
		State.ATTACK:
			attack_state(delta)
		State.LAZER_BEAM:
			lazer_beam_state(delta)
	flip_towards_player()
	
func take_damage(damage):
	damage = damage - defense
	health -= damage
	if health_bar:
		health_bar.value = (float(health) / max_health) * 100
	if health <= 0:
		cyclops_sprite.stop()
		cyclops_sprite.play("death")
		await cyclops_sprite.animation_finished
		queue_free()

func deal_damage(target, damage):
	if target.name == "Player":
		target.take_damage(damage)

func idle_state(delta):
	cyclops_sprite.play("idle")
	if player_in_range(chase_range):
		print("Switching to CHASE state")
		current_state = State.CHASE
		
func chase_state(delta):
	cyclops_sprite.play("run")
	move_towards_player(delta)
	if player_in_range(lazer_range) and lazer_beam_ready:
		print("Switching to LAZER_BEAM state")
		current_state = State.LAZER_BEAM
	elif player_in_range(attack_range):
		print("Switching to ATTACK state")
		current_state = State.ATTACK
	elif not player_in_range(chase_range):
		print("Switching to IDLE state")
		current_state = State.IDLE

func attack_state(delta):
	if is_attacking:
		return
	is_attacking = true
	var rng = RandomNumberGenerator.new()
	rng.randomize() 
	var random_number = rng.randi_range(1, 2)
	if random_number == 1:
		cyclops_sprite.play("stomp")
		await cyclops_sprite.animation_finished
		if in_stomp_range:
			player.take_damage(10)
			print("Player hit by stomp: -10HP")
	else:
		cyclops_sprite.play("throw_rock")  
		await cyclops_sprite.animation_finished
		if in_throw_rock_range:
			player.take_damage(20)
			print("Player hit by throw rock: -20HP")
	is_attacking = false
	print("Switching to CHASE state")
	current_state = State.CHASE
	
func lazer_beam_state(delta):
	if is_attacking:
		return
	is_attacking = true
	cyclops_sprite.play("lazer_beam")
	await cyclops_sprite.animation_finished
	lazer_beam_timer.start()
	lazer_beam_ready = false
	if in_lazer_beam_range:
		player.take_damage(50)
		print("Player hit by lazer beam: -50HP")
	is_attacking = false
	print("Switching to IDLE state")
	current_state = State.IDLE

func player_in_range(range: float) -> bool:
	return position.distance_to(player.position) < range
	
func move_towards_player(delta):
	var direction = (player.position - position).normalized()
	direction.y = 0
	position += direction * speed * delta

# Function to flip the Area2D horizontally
func flip_area2d_horizontally(area: Area2D, flip: bool):
	var scale = Vector2(-1 if flip else 1, 1)
	area.scale = scale

func flip_towards_player():
	if player.position.x < position.x:
		cyclops_sprite.flip_h = true  # Player is to the left, flip horizontally
		flip_area2d_horizontally(stomp_area2d, true)
		flip_area2d_horizontally(throw_rock_area2d, true)
	else:
		cyclops_sprite.flip_h = false
		flip_area2d_horizontally(stomp_area2d, false)
		flip_area2d_horizontally(throw_rock_area2d, false)

func _on_stomp_range_body_entered(body):
	if body == player:
		print("Player entered stomp range")
		in_stomp_range = true

func _on_stomp_range_body_exited(body):
	if body == player:
		print("Player exited stomp range")
		in_stomp_range = false

func _on_throw_rock_range_body_entered(body):
	if body == player:
		print("Player entered throw rock range")
		in_throw_rock_range = true

func _on_throw_rock_range_body_exited(body):
	if body == player:
		print("Player exited throw rock range")
		in_throw_rock_range = false

func _on_lazer_beam_cooldown_timeout():
	print("Lazer beam cooldown reset")
	lazer_beam_ready = true

func _on_lazer_beam_range_body_entered(body):
	if body == player:
		print("Player entered lazer beam range")
		in_lazer_beam_range = true

func _on_lazer_beam_range_body_exited(body):
	if body == player:
		print("Player exited lazer beam range")
		in_lazer_beam_range = false
