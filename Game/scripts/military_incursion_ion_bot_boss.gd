extends Node2D

enum State {
	IDLE,
	CHASE,
	ATTACK,
	LAZER_BEAM,
	SHIELD
}

# Variables for the child nodes
@onready var rigid_body_2d = $RigidBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var chest_canon_range = $chest_canon_range
@onready var attack_range = $attack_range
@onready var charge_timer = $charge_timer
@onready var lazer_beam_range = $lazer_beam_range
@onready var lazer_beam_cooldown = $lazer_beam_cooldown
@onready var shield_range = $shield_range
@onready var shield_cooldown = $shield_cooldown
@onready var health_bar = $RigidBody2D/HealthBar

# Initializing game-state variables (do not change!)
var max_health : int = 500
var health : int = max_health
var attack : int = 85
var defense : int = 40
var player : CharacterBody2D = null
var current_state : State = State.IDLE
var is_attacking : bool = false
var shield_ready : bool = true
var lazer_beam_ready : bool = true
var in_attack_range = false
var in_lazer_beam_range = false
var in_shield_range = false

# Adjust these accordingly
var chase_range: float = 500 # Switches from Idle to Chase
var attack_range_value: float = 35 # Switches from Chase to Attack
var speed: float = 85  # Ion Bot's movement speed
var shield_duration: float = 3.0 # Shield duration in seconds
var shield_cooldown_time: float = 6.0 # Shield cooldown in seconds
var lazer_range = 60 # Range that Ion Bot will use lazer

# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar.value = (float(health) / max_health) * 100
	player = get_parent().get_node("Player")
	if player:
		print("Player node found: ", player)
	else:
		print("Error: Player node not found")

	# Ensure all nodes are properly initialized
	if animated_sprite_2d:
		print("animated_sprite_2d node found")
	else:
		print("Error: animated_sprite_2d node not found")

	if attack_range:
		print("attack_range node found")
	else:
		print("Error: attack_range node not found")

	if lazer_beam_range:
		print("lazer_beam_range node found")
	else:
		print("Error: lazer_beam_range node not found")

	if shield_range:
		print("shield_range node found")
	else:
		print("Error: shield_range node not found")

	if shield_cooldown:
		print("shield_cooldown node found")
	else:
		print("Error: shield_cooldown node not found")

	if lazer_beam_cooldown:
		print("lazer_beam_cooldown node found")
	else:
		print("Error: lazer_beam_cooldown node not found")

	# Connect signals
	attack_range.body_entered.connect(Callable(self, "_on_attack_range_body_entered"))
	attack_range.body_exited.connect(Callable(self, "_on_attack_range_body_exited"))
	shield_range.body_entered.connect(Callable(self, "_on_shield_range_body_entered"))
	shield_range.body_exited.connect(Callable(self, "_on_shield_range_body_exited"))
	shield_cooldown.timeout.connect(Callable(self, "_on_shield_cooldown_timeout"))
	lazer_beam_range.body_entered.connect(Callable(self, "_on_lazer_beam_range_body_entered"))
	lazer_beam_range.body_exited.connect(Callable(self, "_on_lazer_beam_range_body_exited"))
	lazer_beam_cooldown.timeout.connect(Callable(self, "_on_lazer_beam_cooldown_timeout"))

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
		State.SHIELD:
			shield_state(delta)
	flip_towards_player()
	
func take_damage(damage):
	damage = damage - defense
	health -= damage
	if health_bar:
		health_bar.value = (float(health) / max_health) * 100
	if health <= 0:
		animated_sprite_2d.stop()
		animated_sprite_2d.play("death")
		await animated_sprite_2d.animation_finished
		queue_free()

func deal_damage(target, damage):
	if target.name == "Player":
		target.take_damage(damage)

func idle_state(delta):
	animated_sprite_2d.play("idle")
	if player_in_range(chase_range):
		print("Switching to CHASE state")
		current_state = State.CHASE
		
func chase_state(delta):
	animated_sprite_2d.play("run")
	move_towards_player(delta)
	if shield_ready and is_player_in_shield_range():
		print("Switching to SHIELD state")
		current_state = State.SHIELD
	elif player_in_range(lazer_range) and lazer_beam_ready:
		print("Switching to LAZER_BEAM state")
		current_state = State.LAZER_BEAM
	elif player_in_range(attack_range_value):
		print("Switching to ATTACK state")
		current_state = State.ATTACK
	elif not player_in_range(chase_range):
		print("Switching to IDLE state")
		current_state = State.IDLE

func attack_state(delta):
	if is_attacking:
		return
	is_attacking = true
	animated_sprite_2d.play("attack")
	await animated_sprite_2d.animation_finished
	if in_attack_range:
		player.take_damage(20)
		print("Player hit by attack: -20HP")
	is_attacking = false
	print("Switching to CHASE state")
	current_state = State.CHASE

func lazer_beam_state(delta):
	if is_attacking:
		return
	is_attacking = true
	animated_sprite_2d.play("lazer_beam")
	await animated_sprite_2d.animation_finished
	lazer_beam_cooldown.start()
	lazer_beam_ready = false
	if in_lazer_beam_range:
		player.take_damage(50)
		print("Player hit by lazer beam: -50HP")
	is_attacking = false
	print("Switching to IDLE state")
	current_state = State.IDLE

func shield_state(delta):
	if not shield_ready:
		return
	shield_ready = false
	animated_sprite_2d.play("shield")
	await animated_sprite_2d.animation_finished
	print("Ion Bot is shielded for ", shield_duration, " seconds")
	await get_tree().create_timer(shield_duration).timeout
	print("Shield deactivated")
	shield_cooldown.start()
	print("Shield cooldown started")
	current_state = State.IDLE

func player_in_range(range: float) -> bool:
	return position.distance_to(player.position) < range
	
func is_player_in_shield_range() -> bool:
	var shape = shield_range.get_node("CollisionShape2D").shape
	if shape is CircleShape2D:
		return player_in_range(shape.radius)
	elif shape is RectangleShape2D:
		var extents = shape.extents
		var rect = Rect2(shield_range.position - extents, extents * 2)
		return rect.has_point(player.position)
	return false

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
		animated_sprite_2d.flip_h = true  # Player is to the left, flip horizontally
		flip_area2d_horizontally(attack_range, true)
	else:
		animated_sprite_2d.flip_h = false
		flip_area2d_horizontally(attack_range, false)

func _on_attack_range_body_entered(body):
	if body == player:
		print("Player entered attack range")
		in_attack_range = true

func _on_attack_range_body_exited(body):
	if body == player:
		print("Player exited attack range")
		in_attack_range = false

func _on_shield_range_body_entered(body):
	if body == player:
		print("Player entered shield range")
		in_shield_range = true

func _on_shield_range_body_exited(body):
	if body == player:
		print("Player exited shield range")
		in_shield_range = false

func _on_shield_cooldown_timeout():
	print("Shield cooldown reset")
	shield_ready = true

func _on_lazer_beam_range_body_entered(body):
	if body == player:
		print("Player entered lazer beam range")
		in_lazer_beam_range = true

func _on_lazer_beam_range_body_exited(body):
	if body == player:
		print("Player exited lazer beam range")
		in_lazer_beam_range = false

func _on_lazer_beam_cooldown_timeout():
	print("Lazer beam cooldown reset")
	lazer_beam_ready = true

func _on_chest_canon_range_body_entered(body):
	pass # Replace with function body.

func _on_chest_canon_range_body_exited(body):
	pass # Replace with function body.

func _on_charge_timer_timeout():
	pass # Replace with function body.
