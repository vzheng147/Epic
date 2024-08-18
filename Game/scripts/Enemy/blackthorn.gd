extends Node2D

enum State {
	IDLE,
	CHASE,
	ATTACK,
	SKILL,
	ZILTH,
	LANCE,
	MINOTAUR,
	KIBA
}

# variables for the child nodes
@onready var scene = get_parent()
@onready var body = $RigidBody2D
@onready var blackthorn = $RigidBody2D/AnimatedSprite2D
@onready var attack_1_area2d = $RigidBody2D/attack_1_range
@onready var attack_2_area2d = $RigidBody2D/attack_2_range
@onready var skill_area2d = $RigidBody2D/skill_range
@onready var health_bar = $RigidBody2D/HealthBar
@onready var skill_timer = $Skill
@onready var zilth_timer = $Zilth
@onready var lance_timer = $Lance
@onready var minotaur_timer = $Minotaur
@onready var kiba_timer = $Kiba
@onready var damage_timer = $Damage
@onready var fire1 = $Fire1
@onready var fire2 = $Fire2
@onready var fire3 = $Fire3
@onready var fire4 = $Fire4
@onready var aura = $blackthorn_aura
@onready var slash_2 = preload("res://scenes/Enemy/kiba_range_2.tscn")


# initializing game-state variables (do not change!)
var player : CharacterBody2D = null
var current_state : State = State.IDLE
var is_attacking : bool = false
var is_charging : bool = false
var is_using_skill : bool = false
var in_attack_1_range = false
var in_attack_2_range = false
var in_skill_range = false
var in_aura_range = false
var skill_ready = true
var zilth_ready = true
var lance_ready = true
var minotaur_ready = true
var kiba_ready = true

# adjust these accordingly
var max_health : int = 5000
var health : int = max_health
var attack : int = 450
var defense : int = 100
var chase_range: float = 500 # switches from Idle to Chase
var attack_range: float = 44 # switches from Chase to Attack
var speed: float = 105  # movement speed
var skill_range : float = 50
var kiba_range: float = 65


# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar.value = (float(health) / max_health) * 100
	player = get_parent().get_node("Player")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	body.rotation -= body.rotation
	
	if is_charging:
		move_towards_player(delta)
		flip_towards_player()
		return
	
	match current_state:
		State.IDLE:
			idle_state(delta)
		State.CHASE:
			chase_state(delta)
		State.ATTACK:
			attack_state(delta)
		State.SKILL:
			skill_state(delta)
		State.ZILTH:
			zilth_state(delta)
		State.LANCE:
			lance_state(delta)
		State.MINOTAUR:
			minotaur_state(delta)
		State.KIBA:
			kiba_state(delta)
			
	flip_towards_player()

func take_damage(damage):
	damage = damage - defense
	health -= damage
	if health_bar:
		health_bar.value = (float(health) / max_health) * 100
	if health <= 0:
		blackthorn.stop()
		blackthorn.play("death")
		await blackthorn.animation_finished
		scene.boss_death()
		queue_free()

func deal_damage(target, damage):
	if target.name == "Player":
		target.take_damage(damage)

func idle_state(delta):
	blackthorn.play("idle")
	if player_in_range(chase_range):
		current_state = State.CHASE
		
func chase_state(delta):
	blackthorn.play("run")
	move_towards_player(delta)
	
	if minotaur_ready:
		current_state = State.MINOTAUR
	elif lance_ready:
		current_state = State.LANCE
	elif kiba_ready and player_in_range(kiba_range):
		current_state = State.KIBA
	elif zilth_ready:
		current_state = State.ZILTH
	elif player_in_range(skill_range) and skill_ready:
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
		blackthorn.play("attack_1")
		await blackthorn.animation_finished
		if in_attack_1_range:
			player.take_damage(attack)
	else:
		blackthorn.play("attack_2")  
		await blackthorn.animation_finished
		if in_attack_2_range:
			player.take_damage(attack * 1.15)
	
	is_attacking = false
	current_state = State.CHASE
	


func skill_state(delta):
	if (is_attacking):
		return
	is_attacking = true
	
	blackthorn.play("skill")
	
	await blackthorn.animation_finished
	
	if in_skill_range:
		player.take_damage(attack * 2.65)
	
	skill_timer.start()
	is_attacking = false
	skill_ready = false
	current_state = State.CHASE
	

func zilth_state(delta):
	if (is_attacking):
		return
		
	is_attacking = true
	
	blackthorn.play("special")
	await blackthorn.animation_finished
	scene.shoot()
	
	zilth_timer.start()
	zilth_ready = false
	is_attacking = false
	current_state = State.CHASE
	

func lance_state(delta):
	if is_attacking:
		return
	is_attacking = true
	is_charging = true
	
	blackthorn.play("special")
	
	var original_speed = speed
	speed = speed + 62
	
	damage_timer.start()
	aura.visible = true
	blackthorn.play("run")
	await get_tree().create_timer(2.8).timeout
	
	blackthorn.stop()
	aura.visible = false
	speed = original_speed
	
	lance_timer.start()
	is_attacking = false
	is_charging = false
	lance_ready = false
	current_state = State.CHASE
	
	

func minotaur_state(delta):
	if is_attacking:
		return
	
	is_attacking = true
	blackthorn.play("special")
	await blackthorn.animation_finished
	
	activate_fire()
	is_attacking = false
	minotaur_ready = false
	minotaur_timer.start()
	current_state = State.CHASE
	

func kiba_state(delta):
	if (is_attacking):
		return
	is_attacking = true
	
	blackthorn.play("special")
	await blackthorn.animation_finished

	kiba_range_attack()
	await get_tree().create_timer(.4).timeout
	kiba_range_attack()
	
	kiba_timer.start()
	is_attacking = false
	kiba_ready = false
	current_state = State.CHASE
	
	
	
func activate_fire():
	fire1.visible = true
	fire2.visible = true
	fire3.visible = true
	fire4.visible = true
	
	fire1.damage = attack * 1.3
	fire2.damage = attack * 1.3
	fire3.damage = attack * 1.3
	fire4.damage = attack * 1.3
	
	await get_tree().create_timer(3.5).timeout
	
	fire1.visible = false
	fire2.visible = false
	fire3.visible = false
	fire4.visible = false
	
	fire1.damage = 0
	fire2.damage = 0
	fire3.damage = 0
	fire4.damage = 0
	

func kiba_range_attack():
	var instance = slash_2.instantiate()
	instance.pos = blackthorn.global_position + Vector2(0, -10)
	instance.damage = attack * .9
	instance.rot = blackthorn.global_rotation + 3.14
	instance.dir = blackthorn.global_rotation + 1.57
	
	var instance2 = slash_2.instantiate()
	instance2.pos = blackthorn.global_position + Vector2(0, -10)
	instance2.damage = attack * .9
	instance2.rot = blackthorn.global_rotation 
	instance2.dir = blackthorn.global_rotation + 4.71
	
	var instance3 = slash_2.instantiate()
	instance3.pos = blackthorn.global_position
	instance3.damage = attack * .9
	instance3.rot = blackthorn.global_rotation + 4.71
	instance3.dir = blackthorn.global_rotation + 3.14
	
	var instance4 = slash_2.instantiate()
	instance4.pos = blackthorn.global_position
	instance4.damage = attack * .9
	instance4.rot = blackthorn.global_rotation + 5.49
	instance4.dir = blackthorn.global_rotation + 3.92
	
	var instance5 = slash_2.instantiate()
	instance5.pos = blackthorn.global_position
	instance5.damage = attack * .9
	instance5.rot = blackthorn.global_rotation + 3.92
	instance5.dir = blackthorn.global_rotation + 2.35
	
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
		blackthorn.flip_h = true  # Player is to the left, flip horizontally
		flip_area2d_horizontally(attack_1_area2d, true)
		flip_area2d_horizontally(attack_2_area2d, true)
		flip_area2d_horizontally(skill_area2d, true)
	else:
		blackthorn.flip_h = false
		flip_area2d_horizontally(attack_1_area2d, false)
		flip_area2d_horizontally(attack_2_area2d, false)
		flip_area2d_horizontally(skill_area2d, false)


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


func _on_skill_range_body_entered(body):
	if body == player:
		in_skill_range = true


func _on_skill_range_body_exited(body):
	if body == player:
		in_skill_range = false
		
func _on_aura_range_body_entered(body):
	if body == player:
		in_skill_range = true


func _on_aura_range_body_exited(body):
	if body == player:
		in_skill_range = false
		
	
func _on_skill_timeout():
	skill_ready = true
	

func _on_zilth_timeout():
	zilth_ready = true
	
	
func _on_lance_timeout():
	lance_ready = true


func _on_minotaur_timeout():
	minotaur_ready = true
	

func _on_kiba_timeout():
	kiba_ready = true


func _on_damage_timeout():
	if is_charging and in_skill_range:
		player.take_damage(attack * .6)
		damage_timer.start()
