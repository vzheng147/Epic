extends Node2D


enum State {
	IDLE,
	CHASE,
	ATTACK,
	RANGE,
	SKILL,
	ARROWS
}

# variables for the child nodes
@onready var body = $RigidBody2D
@onready var zilth = $RigidBody2D/AnimatedSprite2D
@onready var attack_area2d = $RigidBody2D/attack_range
@onready var skill_area2d = $RigidBody2D/skill_range
@onready var health_bar = $RigidBody2D/HealthBar
@onready var skill_timer = $Skill
@onready var arrows_timer = $Arrows
@onready var range_timer = $Range
@onready var zilth_shadow = preload("res://scenes/Enemy/zilth_shadow.tscn")

# initializing game-state variables (do not change!)
var player : CharacterBody2D = null
var current_state : State = State.IDLE
var is_attacking : bool = false
var in_attack_range = false
var in_skill_range = false
var skill_ready = true
var arrows_ready = false
var range_ready = false

# adjust these accordingly
var max_health : int = 350
var health : int = max_health
var attack : int = 75
var defense : int = 10
var chase_range: float = 500 # switches from Idle to Chase
var attack_range: float = 38 # switches from Chase to Attack
var speed: float = 100  # movement speed
var skill_range : float = 44


# Called when the node enters the scene tree for the first time.
func _ready():
	arrows_timer.start()
	range_timer.start()
	health_bar.value = (float(health) / max_health) * 100
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
		State.RANGE:
			range_state(delta)
		State.SKILL:
			skill_state(delta)
		State.ARROWS:
			arrows_state(delta)
	flip_towards_player()

func take_damage(damage):
	damage = damage - defense
	health -= damage
	if health_bar:
		health_bar.value = (float(health) / max_health) * 100
	if health <= 0:
		zilth.stop()
		zilth.play("death")
		await zilth.animation_finished
		queue_free()

func deal_damage(target, damage):
	if target.name == "Player":
		target.take_damage(damage)

func idle_state(delta):
	zilth.play("idle")
	if player_in_range(chase_range):
		current_state = State.CHASE
		
func chase_state(delta):
	zilth.play("run")
	move_towards_player(delta)
	
	if arrows_ready:
		current_state = State.ARROWS
	elif range_ready:
		current_state = State.RANGE
	elif skill_ready and player_in_range(skill_range):
		current_state = State.SKILL
	elif player_in_range(attack_range):
		current_state = State.ATTACK
	elif not player_in_range(chase_range):
		current_state = State.IDLE
	else:
		current_state = State.CHASE

func attack_state(delta):
	
	if is_attacking:
		return
		
	is_attacking = true
	
	var rng = RandomNumberGenerator.new()
	rng.randomize() 
	var random_number = rng.randi_range(1, 2)
	
	if random_number == 1:
		zilth.play("attack_1")
		await zilth.animation_finished
		if in_attack_range:
			player.take_damage(attack * 1.15)
	else:
		zilth.play("attack_2")  
		await zilth.animation_finished
		if in_attack_range:
			player.take_damage(attack)
	
	is_attacking = false
	skill_ready = false
	current_state = State.CHASE
	
func range_state(delta):
	if (is_attacking):
		return
		
	is_attacking = true
	
	zilth.play("range")
	if in_skill_range:
		deal_damage(player, attack * 1.5)
	range_attack()
	
	await get_tree().create_timer(.5).timeout
	if in_skill_range:
		deal_damage(player, attack * 1.5)
	range_attack()
	
	await get_tree().create_timer(.5).timeout
	if in_skill_range:
		deal_damage(player, attack * 1.5)
	range_attack()
	
	await zilth.animation_finished
	if in_skill_range:
		deal_damage(player, attack * 1.5)
	range_attack()
	
	range_timer.start()
	range_ready = false
	is_attacking = false
	current_state = State.CHASE


func skill_state(delta):
	if (is_attacking):
		return
	is_attacking = true
	
	zilth.play("skill")
	await zilth.animation_finished
	skill_timer.start()
	skill_ready = false
	
	if in_skill_range:
		player.take_damage(attack * 2.25)
	
	is_attacking = false
	current_state = State.CHASE
	
func arrows_state(delta):
	if (is_attacking):
		return
		
	is_attacking = true
	
	zilth.play("arrows")
	await zilth.animation_finished
	
	arrows_timer.start()
	arrows_ready = false
	is_attacking = false
	current_state = State.CHASE
	
	
func range_attack():
	var instance = zilth_shadow.instantiate()
	instance.flip = zilth.flip_h
	instance.damage = attack * 1.3
	instance.spawnPosition = zilth.global_position
	get_parent().add_child(instance)


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
		zilth.flip_h = true  # Player is to the left, flip horizontally
		flip_area2d_horizontally(attack_area2d, true)
		flip_area2d_horizontally(skill_area2d, true)
	else:
		zilth.flip_h = false
		flip_area2d_horizontally(attack_area2d, false)
		flip_area2d_horizontally(skill_area2d, true)



func _on_attack_range_body_entered(body):
	in_attack_range = true

func _on_attack_range_body_exited(body):
	in_attack_range = false


func _on_skill_timeout():
	skill_ready = true


func _on_skill_range_body_entered(body):
	in_skill_range = true


func _on_skill_range_body_exited(body):
	in_skill_range = false


func _on_arrows_timeout():
	arrows_ready = true


func _on_range_timeout():
	range_ready = true
