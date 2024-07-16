extends Node2D

enum State {
	IDLE,
	CHASING,
	ATTACKING,
}

@onready var rat = $rat_sprite

var player : CharacterBody2D = null
var current_state : State = State.IDLE

# Adjust these ranges as per your game design
var chase_range: float = 300
var attack_range: float = 30
var speed: float = 75  # Rat's movement speed

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
	rat.play("attack")
	if player_in_range(attack_range):
		apply_damage_to_player()
	if not player_in_range(attack_range):
		current_state = State.CHASING

func player_in_range(range: float) -> bool:
	return position.distance_to(player.position) < range

func move_towards_player(delta):
	var direction = (player.position - position).normalized()
	position += direction * speed * delta

func apply_damage_to_player():
	if player:
		pass # Assuming your player node has a take_damage method


func flip_towards_player():
	if player.position.x < position.x:
		rat.flip_h = true  # Player is to the left, flip horizontally
	else:
		rat.flip_h = false
	

