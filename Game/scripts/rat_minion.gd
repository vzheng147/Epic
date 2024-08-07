extends Node2D

enum State {
	IDLE,
	CHASING,
	ATTACKING
}


@export var respawn_time : int
@export var respawn_location : Vector2
@export var sight_range : Area2D

@onready var root_scene = get_parent()
@onready var body = $RigidBody2D
@onready var rat = $RigidBody2D/rat_sprite
@onready var attack_area2d = $RigidBody2D/attack_range
@onready var health_bar = $RigidBody2D/HealthBar

# initializing game-state variables (do not change!)
var player : CharacterBody2D
var current_state : State = State.IDLE
var player_in_attack_range : bool = false
var is_attacking : bool = false
var is_pausing : bool = false

# Adjust these ranges as per your game design
var gold : int = 10
var xp : int = 15
var max_health : int = 200
var health : int = max_health
var attack : int = 50
var defense : int = 5
var chase_range: float = 500
var attack_range: float = 30
var speed: float = 85  # Rat's movement speed

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_node("Player")
	health_bar.value = (float(health) / max_health) * 100
	health = max_health
	global_position = respawn_location


func take_damage(damage):
	damage = damage - defense
	health -= damage
	if health_bar:
		health_bar.value = (float(health) / max_health) * 100
	if health <= 0:
		rat.stop()
		rat.play("death")
		await rat.animation_finished
		root_scene.spawn(scene_file_path, sight_range, respawn_location, respawn_time)
		player.gain_gold_and_xp(gold, xp)
		queue_free()
		
	

func deal_damage(target, damage):
	if target.name == "Player":
		target.take_damage(damage)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	body.rotation -= body.rotation
	
	if is_pausing:
		return
	
	match current_state:
		State.IDLE:
			idle_state(delta)
			return
		State.CHASING:
			chasing_state(delta)
		State.ATTACKING:
			attacking_state(delta)
	flip_towards_player()

func idle_state(delta):	
	
	if global_position.distance_to(respawn_location) > 5:
		rat.play("run")
		move_towards_idle(delta)
	else:
		rat.play("idle")
		
	if sight_range.player_in_range and player_in_range(chase_range):
		current_state = State.CHASING
	

func chasing_state(delta):
	rat.play("run")
	move_towards_player(delta)
	if player_in_range(attack_range):
		current_state = State.ATTACKING
	# pauses for one second before moving back to idle position
	elif not player_in_range(chase_range) or not sight_range.player_in_range:
		pause(.5)
		current_state = State.IDLE

func attacking_state(delta):
	if is_attacking:
		return
		
	is_attacking = true
	rat.play("attack")
	await rat.animation_finished
	
	if player_in_attack_range:
		player.take_damage(30)
	
	is_attacking = false
	current_state = State.CHASING

func player_in_range(range: float) -> bool:
	return position.distance_to(player.position) < range

func move_towards_player(delta):
	var direction = (player.position - position).normalized()
	direction.y = 0
	position += direction * speed * delta

func move_towards_idle(delta):
	var direction = (respawn_location - position).normalized()
	direction.y = 0
	
	# ensure the sprite is facing the right way
	if direction.x > 0:
		rat.flip_h = false
	else:
		rat.flip_h = true
		
	position += direction * speed * delta

# Function to flip the Area2D horizontally
func flip_area2d_horizontally(area: Area2D, flip: bool):
	var scale = Vector2(-1 if flip else 1, 1)
	area.scale = scale


func flip_towards_player():
	if player.position.x < position.x:
		rat.flip_h = true  # Player is to the left, flip horizontally
		flip_area2d_horizontally(attack_area2d, true)
	else:
		rat.flip_h = false
		flip_area2d_horizontally(attack_area2d, false)
	
func pause(time):
	rat.stop()
	rat.play("idle")
	is_pausing = true
	await get_tree().create_timer(time).timeout
	is_pausing = false

func _on_attack_range_body_entered(body):
	if body.name == "Player":
		player_in_attack_range = true


func _on_attack_range_body_exited(body):
	if body.name == "Player":
		player_in_attack_range = false


