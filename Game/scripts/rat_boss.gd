extends Node2D

enum State {
	IDLE,
	CHASING,
	ATTACKING,
	SKILL,
	SUMMON
}

@onready var rat := $RigidBody2D/rat_sprite
@onready var health_bar = $RigidBody2D/HealthBar
@onready var attack_area2d := $RigidBody2D/attack_range
@onready var skill_timer := $RigidBody2D/skill_timer
@onready var summon_timer := $RigidBody2D/summon_timer

# initializing game-state variables (do not change!)
var player : CharacterBody2D = null
var current_state : State = State.IDLE
var player_in_attack_range : bool = false
var skill_ready : bool = true
var summon_ready : bool = false
var is_attacking : bool = false
var is_summoning : bool = false

# Adjust these ranges as per your game design
var max_health : int = 250
var health : int = max_health
var attack : int = 50
var defense : int = 5
var chase_range: float = 500
var attack_range: float = 35
var speed: float = 85  # Rat's movement speed
	
# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar.value = (float(health) / max_health) * 100
	player = get_parent().get_node("Player")

@onready var body = $RigidBody2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rat.rotation = 0
	match current_state:
		State.IDLE:
			idle_state(delta)
		State.CHASING:
			chasing_state(delta)
		State.ATTACKING:
			attacking_state(delta)
		State.SKILL:
			skill_state(delta)
		State.SUMMON:
			summon_state(delta)
	flip_towards_player()

func take_damage(damage):
	damage = damage - defense
	health -= damage
	if health_bar:
		health_bar.value = (float(health) / max_health) * 100
	if health <= 0:
		rat.play("death")
		await rat.animation_finished
		queue_free()

func deal_damage(target, damage):
	if target.name == "Player":
		target.take_damage(damage)
	
	
func idle_state(delta):
	rat.play("idle")
	if player_in_range(chase_range):
		current_state = State.CHASING

func chasing_state(delta):
	rat.play("run")
	move_towards_player(delta)
	if (summon_ready):
		current_state = State.SUMMON
	elif player_in_range(attack_range):
		if (skill_ready):
			current_state = State.SKILL
		else:
			current_state = State.ATTACKING
	elif not player_in_range(chase_range):
		current_state = State.IDLE

func attacking_state(delta):
	
	if is_attacking:
		return
	is_attacking = true
	
	rat.play("attack")
	await rat.animation_finished
	if player_in_attack_range:
		deal_damage(player, attack)
		
	is_attacking = false
	
	if (summon_ready):
		current_state = State.SUMMON
	else:
		current_state = State.CHASING
		
func skill_state(delta):
	if is_attacking:
		return
	is_attacking = true
	
	rat.play("skill")
	await rat.animation_finished
	skill_ready = false
	skill_timer.start()
	
	if player_in_attack_range:
		deal_damage(player, attack * 3)
		
	is_attacking = false
	
	if (summon_ready):
		current_state = State.SUMMON
	else:
		current_state = State.CHASING

func summon_state(delta):
	if is_summoning:
		return
	is_summoning = true
	var rat_minion_scene = preload("res://scenes/Enemy/rat_minion.tscn")
	rat.play("summon");
	await rat.animation_finished	
	var rat_minion_instance = rat_minion_scene.instantiate()
	rat_minion_instance.position = position + Vector2(10, 30)# Set the position to the boss's position
	get_tree().current_scene.add_child(rat_minion_instance)  # Add the rat minion to the root of the current scen
	summon_ready = false  
	is_summoning = false
	summon_timer.start()
	current_state = State.CHASING  # Transition to the CHASING state

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


func _on_summon_timer_timeout():
	summon_ready = true
