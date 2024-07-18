extends Node2D

enum State {
	IDLE,
	CHASING,
	ATTACKING,
}

@onready var rat := $rat_sprite
@onready var attack_area2d := $attack_range
@onready var skill_timer := $skill_timer

# initializing game-state variables (do not change!)
var player : CharacterBody2D = null
var current_state : State = State.IDLE
var player_in_attack_range : bool = false
var skill_ready : bool = true
var is_attacking : bool = false

# Adjust these ranges as per your game design
var chase_range: float = 500
var attack_range: float = 35
var speed: float = 85  # Rat's movement speed

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_node("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match current_state:
		State.IDLE:
			idle_state(delta)
		State.CHASING:
			chasing_state(delta)
		State.ATTACKING:
			attacking_state(delta)
	flip_towards_player()

func idle_state(delta):
	rat.play("idle")
	if player_in_range(chase_range):
		current_state = State.CHASING

func chasing_state(delta):
	rat.play("run")
	move_towards_player(delta)
	if player_in_range(attack_range):
		current_state = State.ATTACKING
	elif not player_in_range(chase_range):
		current_state = State.IDLE

func attacking_state(delta):
	
	if is_attacking:
		return
	is_attacking = true
	
	if skill_ready:
		rat.play("attack2")
		await rat.animation_finished
		skill_ready = false
		skill_timer.start()
		if player_in_attack_range:
			player.take_damage(150)
	else:
		rat.play("attack")
		await rat.animation_finished
		if player_in_attack_range:
			player.take_damage(60)
		
	is_attacking = false
	current_state = State.CHASING
	

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


func flip_towards_player():
	if player.position.x < position.x:
		rat.flip_h = true  # Player is to the left, flip horizontally
		flip_area2d_horizontally(attack_area2d, true)
	else:
		rat.flip_h = false
		flip_area2d_horizontally(attack_area2d, false)
	

func _on_attack_range_body_entered(body):
	if body.name == "Player":
		player_in_attack_range = true



func _on_attack_range_body_exited(body):
	if body.name == "Player":
		player_in_attack_range = false


func _on_skill_timer_timeout():
	skill_ready = true
