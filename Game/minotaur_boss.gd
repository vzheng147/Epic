extends Node2D

enum State {
	IDLE,
	PURSUE,
	ATTACK,
	CHARGE,
}

@onready var minotaur_sprite = $minotaur_sprite
@onready var attack_area2d := $attack_range
@onready var charge_timer = $charge_timer


var player : CharacterBody2D = null
var current_state : State = State.IDLE
var player_in_attack_range : bool = false
var charge_ready : bool = true

# Adjust these ranges as per your game design
var pursue_range: float = 500
var attack_range: float = 34
var speed: float = 80  # Ox's movement speed
var charge_speed: float = 160  # Ox's charge speed
var charge_duration: float = 2.0  # Duration for the charge state
var charge_timer_value: float = 5.0  # Cooldown time for the charge ability

func _ready():
	player = get_parent().get_node("Player")

func _process(delta):
	match current_state:
		State.IDLE:
			idle_state(delta)
		State.PURSUE:
			pursue_state(delta)
		State.ATTACK:
			attack_state(delta)
	flip_towards_player()

func idle_state(delta):
	minotaur_sprite.play("idle")
	if player_in_range(pursue_range):
		current_state = State.PURSUE

func pursue_state(delta):
	minotaur_sprite.play("run")
	move_towards_player(delta)
	if player_in_range(attack_range):
		current_state = State.ATTACK

func attack_state(delta):
	if charge_ready:
		minotaur_sprite.play("charge")
		await minotaur_sprite.animation_finished
		if player_in_attack_range:
			player.take_damage(190 * delta)
		charge_ready = false
		charge_timer.start()
	else:
		minotaur_sprite.play("attack1")
		await minotaur_sprite.animation_finished
		if player_in_attack_range:
			player.take_damage(190 * delta)
	current_state = State.PURSUE


func player_in_range(range: float) -> bool:
	return position.distance_to(player.position) < range

func move_towards_player(delta):
	var direction = (player.position - position).normalized()
	position += direction * speed * delta

func flip_area2d_horizontally(area: Area2D, flip: bool):
	var scale = Vector2(-1 if flip else 1, 1)
	area.scale = scale

func flip_towards_player():
	if player.position.x < position.x:
		minotaur_sprite.flip_h = true
		flip_area2d_horizontally(attack_area2d, true)
	else:
		minotaur_sprite.flip_h = false
		flip_area2d_horizontally(attack_area2d, false)

func _on_attack_range_body_entered(body):
	print("entered")
	print(player_in_attack_range)
	if body.name == "Player":
		player_in_attack_range = true

func _on_attack_range_body_exited(body):
	print("exited")
	print(player_in_attack_range)
	if body.name == "Player":
		player_in_attack_range = false

func _on_charge_timer_timeout():
	charge_ready = true
