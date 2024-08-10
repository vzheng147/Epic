extends Node2D

enum State {
	IDLE,
	CHASE,
	ATTACK,
	SWIRL,
	FIRE
}

# variables for the child nodes
@onready var body = $RigidBody2D
@onready var minotaur = $RigidBody2D/minotaur_sprite
@onready var attack_1_area2d = $RigidBody2D/attack_1_range
@onready var attack_2_area2d = $RigidBody2D/attack_2_range
@onready var swirl_area2d = $RigidBody2D/swirl_range
@onready var swirl_timer = $swirl_cooldown
@onready var fire_timer = $fire_timer
@onready var health_bar = $RigidBody2D/HealthBar
@onready var fire1 = $Fire
@onready var fire2 = $Fire2
@onready var fire3 = $Fire3
@onready var fire4 = $Fire4
@onready var fire5 = $Fire5
@onready var fire6 = $Fire6

# initializing game-state variables (do not change!)
var player : CharacterBody2D = null
var current_state : State = State.IDLE
var is_attacking : bool = false
var is_using_fire : bool = false
var swirl_ready : bool = true
var fire_ready : bool = true
var in_attack_1_range = false
var in_attack_2_range = false
var in_swirl_range = false

# adjust these accordingly
var max_health : int = 350
var health : int = max_health
var attack : int = 75
var defense : int = 10
var chase_range: float = 500 # switches from Idle to Chase
var attack_range: float = 35 # switches from Chase to Attack
var speed: float = 85  # Minotaur's movement speed
var swirl_range = 44 # range that Minotaur will use swirl

# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar.value = (float(health) / max_health) * 100
	fire1.damage = 0
	fire2.damage = 0
	fire3.damage = 0
	fire4.damage = 0
	fire5.damage = 0
	player = get_parent().get_node("Player")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	body.rotation -= body.rotation
	
	match current_state:
		State.IDLE:
			idle_state(delta)
		State.CHASE:
			chase_state(delta)
		State.ATTACK:
			attack_state(delta)
		State.SWIRL:
			swirl_state(delta)
		State.FIRE:
			fire_state(delta)
	flip_towards_player()

func take_damage(damage):
	damage = damage - defense
	health -= damage
	if health_bar:
		health_bar.value = (float(health) / max_health) * 100
	if health <= 0:
		minotaur.stop()
		minotaur.play("death")
		await minotaur.animation_finished
		queue_free()

func deal_damage(target, damage):
	if target.name == "Player":
		target.take_damage(damage)

func idle_state(delta):
	minotaur.play("idle")
	if player_in_range(chase_range):
		current_state = State.CHASE
		
func chase_state(delta):
	minotaur.play("run")
	move_towards_player(delta)
	if fire_ready:
		current_state = State.FIRE
	elif player_in_range(swirl_range) and swirl_ready:
		current_state = State.SWIRL
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
		minotaur.play("attack2")
		await minotaur.animation_finished
		if in_attack_1_range:
			player.take_damage(10)
	else:
		minotaur.play("attack1")  
		await minotaur.animation_finished
		if in_attack_2_range:
			player.take_damage(20)
	
	is_attacking = false
	current_state = State.CHASE
	
func swirl_state(delta):
	
	if (is_attacking):
		return
	is_attacking = true
	
	minotaur.play("swirl")
	await minotaur.animation_finished
	swirl_timer.start()
	swirl_ready = false
	
	if in_swirl_range:
		player.take_damage(50)
	
	is_attacking = false
	current_state = State.CHASE
	
func fire_state(delta):
	
	if is_using_fire:
		return
	
	is_using_fire = true
	minotaur.play("fire")
	await minotaur.animation_finished
	
	activate_fire()
	is_using_fire = false
	fire_ready = false
	fire_timer.start()
	current_state = State.CHASE

func activate_fire():
	fire1.visible = true
	fire2.visible = true
	fire3.visible = true
	fire4.visible = true
	fire5.visible = true
	fire6.visible = true
	
	fire1.damage = attack * 1.8
	fire2.damage = attack * 1.8
	fire3.damage = attack * 1.8
	fire4.damage = attack * 1.8
	fire5.damage = attack * 1.8
	fire6.damage = attack * 1.8
	
	await get_tree().create_timer(4.0).timeout
	
	fire1.visible = false
	fire2.visible = false
	fire3.visible = false
	fire4.visible = false
	fire5.visible = false
	fire6.visible = false
	
	fire1.damage = 0
	fire2.damage = 0
	fire3.damage = 0
	fire4.damage = 0
	fire5.damage = 0
	fire6.damage = 0

func player_in_range(range: float) -> bool:
	return position.distance_to(player.position) < range
	
func move_towards_player(delta):
	var direction = (player.position - position).normalized()
	direction.y = 0;
	position += direction * speed * delta

# Function to flip the Area2D horizontally
func flip_area2d_horizontally(area: Area2D, flip: bool):
	var scale = Vector2(-1 if flip else 1, 1)
	area.scale = scale

# Function to flip the Area2D horizontally
func flip_towards_player():
	if player.position.x < position.x:
		minotaur.flip_h = true  # Player is to the left, flip horizontally
		flip_area2d_horizontally(attack_1_area2d, true)
		flip_area2d_horizontally(attack_2_area2d, true)
	else:
		minotaur.flip_h = false
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


func _on_swirl_range_body_entered(body):
	if body == player:
		in_swirl_range = true

func _on_swirl_range_body_exited(body):
	if body == player:
		in_swirl_range = false


func _on_swirl_cooldown_timeout():
	swirl_ready = true
	
func _on_fire_timer_timeout():
	fire_ready = true
