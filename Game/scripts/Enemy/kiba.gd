extends Node2D

enum State {
	IDLE,
	CHASE,
	ATTACK,
	SKILL,
	RANGE,
	SPECIAL
}

# variables for the child nodes
@onready var scene = get_parent()
@onready var body = $RigidBody2D
@onready var kiba = $RigidBody2D/AnimatedSprite2D
@onready var attack_area2d = $RigidBody2D/attack_range
@onready var skill_area2d = $RigidBody2D/skill_range
@onready var health_bar = $RigidBody2D/HealthBar
@onready var skill_timer = $Skill
@onready var range_timer = $Range
@onready var special_timer = $Special
@onready var damage_timer = $Damage
@onready var slash_1 = preload("res://scenes/Enemy/kiba_range_1.tscn")
@onready var slash_2 = preload("res://scenes/Enemy/kiba_range_2.tscn")


# initializing game-state variables (do not change!)
var player : CharacterBody2D = null
var current_state : State = State.IDLE
var is_attacking : bool = false
var is_using_skill : bool = false
var in_attack_range = false
var in_skill_range = false
var skill_ready = true
var special_ready = false
var range_ready = true

# adjust these accordingly
var max_health : int = 350
var health : int = max_health
var attack : int = 75
var defense : int = 10
var chase_range: float = 500 # switches from Idle to Chase
var attack_range: float = 44 # switches from Chase to Attack
var speed: float = 120  # movement speed
var skill_range : float = 250
var special_range: float = 70


# Called when the node enters the scene tree for the first time.
func _ready():
	special_timer.start()
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
		State.SKILL:
			skill_state(delta)
		State.RANGE:
			range_state(delta)
		State.SPECIAL:
			special_state(delta)
	flip_towards_player()

func take_damage(damage):
	damage = damage - defense
	health -= damage
	if health_bar:
		health_bar.value = (float(health) / max_health) * 100
	if health <= 0:
		kiba.stop()
		kiba.play("death")
		await kiba.animation_finished
		scene.boss_death()
		queue_free()

func deal_damage(target, damage):
	if target.name == "Player":
		target.take_damage(damage)

func idle_state(delta):
	kiba.play("idle")
	if player_in_range(chase_range):
		current_state = State.CHASE
		
func chase_state(delta):
	kiba.play("run")
	move_towards_player(delta)
	
	if range_ready:
		current_state = State.RANGE
	elif skill_ready and player_in_range(skill_range):
		current_state = State.SKILL
	elif special_ready and player_in_range(special_range):
		current_state = State.SPECIAL
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
	
	kiba.play("attack")
	await kiba.animation_finished
	if in_attack_range:
		player.take_damage(attack)
	
	is_attacking = false
	skill_ready = false
	current_state = State.CHASE
	


func skill_state(delta):
	if (is_attacking):
		return
	is_attacking = true
	
	kiba.play("skill")
	
	await get_tree().create_timer(.9).timeout
	var player_back : int
	if player.animated_sprite.flip_h == false:
		player_back = -30
	if player.animated_sprite.flip_h == true:
		player_back = 30
		
	position.x = player.position.x + player_back
	is_using_skill = true
	damage_timer.start()
		
	await kiba.animation_finished
	
	if in_skill_range:
		player.take_damage(attack * 2.25)
	
	skill_timer.start()
	is_attacking = false
	is_using_skill = false
	skill_ready = false
	current_state = State.CHASE
	
func range_state(delta):
	if (is_attacking):
		return
	is_attacking = true
	
	kiba.play("range")
	await kiba.animation_finished
	
	range_attack_1()
	await get_tree().create_timer(.2).timeout
	range_attack_1()
	
	is_attacking = false
	range_ready = false
	range_timer.start()
	current_state = State.CHASE
	

func special_state(delta):
	if (is_attacking):
		return
	is_attacking = true
	
	kiba.play("special")
	await kiba.animation_finished

	range_attack_2()
	await get_tree().create_timer(.35).timeout
	range_attack_2()
	
	range_timer.start()
	is_attacking = false
	special_ready = false
	current_state = State.CHASE

func range_attack_1():
	var instance = slash_1.instantiate()
	instance.flip = kiba.flip_h
	instance.damage = attack * 1.35
	instance.spawnPosition = kiba.global_position + Vector2(0, -10)
	get_parent().add_child(instance)

func range_attack_2():
	var instance = slash_2.instantiate()
	instance.pos = kiba.global_position + Vector2(0, -10)
	instance.damage = attack * 1.25
	instance.rot = kiba.global_rotation + 3.14
	instance.dir = kiba.global_rotation + 1.57
	
	var instance2 = slash_2.instantiate()
	instance2.pos = kiba.global_position + Vector2(0, -10)
	instance2.damage = attack * 1.25
	instance2.rot = kiba.global_rotation 
	instance2.dir = kiba.global_rotation + 4.71
	
	var instance3 = slash_2.instantiate()
	instance3.pos = kiba.global_position
	instance3.damage = attack * 1.25
	instance3.rot = kiba.global_rotation + 4.71
	instance3.dir = kiba.global_rotation + 3.14
	
	var instance4 = slash_2.instantiate()
	instance4.pos = kiba.global_position
	instance4.damage = attack * 1.25
	instance4.rot = kiba.global_rotation + 5.49
	instance4.dir = kiba.global_rotation + 3.92
	
	var instance5 = slash_2.instantiate()
	instance5.pos = kiba.global_position
	instance5.damage = attack * 1.25
	instance5.rot = kiba.global_rotation + 3.92
	instance5.dir = kiba.global_rotation + 2.35
	
	get_parent().add_child(instance)
	get_parent().add_child(instance2)
	get_parent().add_child(instance3)
	get_parent().add_child(instance4)
	get_parent().add_child(instance5)

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
		kiba.flip_h = true  # Player is to the left, flip horizontally
		flip_area2d_horizontally(attack_area2d, true)
		flip_area2d_horizontally(skill_area2d, true)
	else:
		kiba.flip_h = false
		flip_area2d_horizontally(attack_area2d, false)
		flip_area2d_horizontally(skill_area2d, false)


func _on_attack_range_body_entered(body):
	if body.name == "Player":
		in_attack_range = true


func _on_attack_range_body_exited(body):
	if body.name == "Player":
		in_attack_range = false
	

func _on_skill_range_body_entered(body):
	if body.name == "Player":
		in_skill_range = true


func _on_skill_range_body_exited(body):
	if body.name == "Player":
		in_skill_range = false


func _on_skill_timeout():
	skill_ready = true
	

func _on_range_timeout():
	range_ready = true


func _on_special_timeout():
	special_ready = true


func _on_damage_timeout():
	if is_using_skill and in_skill_range:
		player.take_damage(attack * .65)
		damage_timer.start()
