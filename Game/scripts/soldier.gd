extends Node2D

enum State {
	IDLE,
	CHASE,
	ATTACK,
	ARCHERY
}

# Variables for the child nodes
@onready var soldier_sprite = $RigidBody2D/soldier_sprite
@onready var attack_1_area2d = $RigidBody2D/attack_1_range
@onready var attack_2_area2d = $RigidBody2D/attack_2_range
@onready var archery_area2d = $RigidBody2D/archery_range
@onready var archery_timer = $RigidBody2D/archery_cooldown
@onready var health_bar = $RigidBody2D/HealthBar

# Initializing game-state variables (do not change!)
var player : CharacterBody2D = null
var current_state : State = State.IDLE
var is_attacking : bool = false
var archery_ready : bool = true
var in_attack_1_range = false
var in_attack_2_range = false
var in_archery_range = false

# Adjust these accordingly
var max_health : int = 100
var health : int = max_health
var attack : int = 20
var defense : int = 3
var chase_range: float = 500 # Switches from Idle to Chase
var attack_range: float = 35 # Switches from Chase to Attack
var speed: float = 85  # Soldier's movement speed
var archery_range = 300 # Range that Soldier will use archery

# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar.value = (float(health) / max_health) * 100
	player = get_parent().get_node("Player")
	
	if !soldier_sprite:
		print("Error: soldier_sprite node not found")
	if !attack_1_area2d:
		print("Error: attack_1_area2d node not found")
	if !attack_2_area2d:
		print("Error: attack_2_area2d node not found")
	if !archery_area2d:
		print("Error: archery_area2d node not found")
	if !archery_timer:
		print("Error: archery_timer node not found")
	
	# Connect signals
	if attack_1_area2d:
		attack_1_area2d.body_entered.connect(Callable(self, "_on_attack_1_range_body_entered"))
		attack_1_area2d.body_exited.connect(Callable(self, "_on_attack_1_range_body_exited"))
	if attack_2_area2d:
		attack_2_area2d.body_entered.connect(Callable(self, "_on_attack_2_range_body_entered"))
		attack_2_area2d.body_exited.connect(Callable(self, "_on_attack_2_range_body_exited"))
	if archery_area2d:
		archery_area2d.body_entered.connect(Callable(self, "_on_archery_range_body_entered"))
		archery_area2d.body_exited.connect(Callable(self, "_on_archery_range_body_exited"))
	if archery_timer:
		archery_timer.timeout.connect(Callable(self, "_on_archery_cooldown_timeout"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match current_state:
		State.IDLE:
			idle_state(delta)
		State.CHASE:
			chase_state(delta)
		State.ATTACK:
			attack_state(delta)
		State.ARCHERY:
			archery_state(delta)
	flip_towards_player()
	
func take_damage(damage):
	damage = damage - defense
	health -= damage
	health_bar.value = (float(health) / max_health) * 100
	if health <= 0:
		if soldier_sprite:
			soldier_sprite.stop()
			soldier_sprite.play("death")
			await soldier_sprite.animation_finished
		queue_free()

func deal_damage(target, damage):
	if target.name == "Player":
		target.take_damage(damage)
		
func idle_state(delta):
	if soldier_sprite:
		soldier_sprite.play("idle")
	if player_in_range(chase_range):
		current_state = State.CHASE
		
func chase_state(delta):
	if soldier_sprite:
		soldier_sprite.play("run")
	move_towards_player(delta)
	if player_in_range(archery_range) and archery_ready:
		current_state = State.ARCHERY
	elif player_in_range(attack_range):
		current_state = State.ATTACK
	elif not player_in_range(chase_range):
		current_state = State.IDLE
		
func attack_state(delta):
	if is_attacking:
		return
	is_attacking = true
	var rng = RandomNumberGenerator.new()
	rng.randomize() 
	var random_number = rng.randi_range(1, 2)
	if random_number == 1:
		if soldier_sprite:
			soldier_sprite.play("attack2")
			await soldier_sprite.animation_finished
		if in_attack_1_range:
			player.take_damage(10)
	else:
		if soldier_sprite:
			soldier_sprite.play("attack1")
			await soldier_sprite.animation_finished
		if in_attack_2_range:
			player.take_damage(20)
	
	is_attacking = false
	current_state = State.CHASE
	
func archery_state(delta):
	if is_attacking:
		return
	is_attacking = true
	if soldier_sprite:
		soldier_sprite.play("archery")
		await soldier_sprite.animation_finished
	if archery_timer:
		archery_timer.start()
	archery_ready = false
	if in_archery_range:
		player.take_damage(50)
	is_attacking = false
	current_state = State.CHASE
	
func player_in_range(range: float) -> bool:
	return position.distance_to(player.position) < range
	
func move_towards_player(delta):
	var direction = (player.position - position).normalized()
	direction.y = 0
	position += direction * speed * delta
	
# Function to flip the Area2D horizontally
func flip_area2d_horizontally(area: Area2D, flip: bool):
	if area:
		var scale = Vector2(-1 if flip else 1, 1)
		area.scale = scale
	
# Function to flip the sprite and attack areas towards the player
func flip_towards_player():
	if player.position.x < position.x:
		if soldier_sprite:
			soldier_sprite.flip_h = true  # Player is to the left, flip horizontally
		flip_area2d_horizontally(attack_1_area2d, true)
		flip_area2d_horizontally(attack_2_area2d, true)
	else:
		if soldier_sprite:
			soldier_sprite.flip_h = false
		flip_area2d_horizontally(attack_1_area2d, false)
		flip_area2d_horizontally(attack_2_area2d, false)

func _on_attack_1_range_body_entered(body):
	if body == player:
		in_attack_1_range = true

func _on_attack_1_range_body_exited(body):
	if body == player:
		in_attack_1_range = false

func _on_attack_2_range_body_entered(body):
	if body == player:
		in_attack_2_range = true

func _on_attack_2_range_body_exited(body):
	if body == player:
		in_attack_2_range = false

func _on_archery_cooldown_timeout():
	archery_ready = true

func _on_archery_range_body_entered(body):
	if body == player:
		in_archery_range = true

func _on_archery_range_body_exited(body):
	if body == player:
		in_archery_range = false
