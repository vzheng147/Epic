extends CharacterBody2D
#this is the script that will move around our character 
@onready var inventory = $Inventory
@onready var flash_animation = $FlashAnimation
@onready var health_bar = $HealthBar
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_range = $attack_range
@onready var recover_timer = $Recover_Timer
@onready var one_second_heal = $OneSecondHeal
@onready var dash_timer = $Dash_Timer

# state variables (do not change)
var is_attacking = false
var is_dashing = false
var dash_ready = true
var in_attack_range = []
var is_recovering = false
var is_healing_one = false


var SPEED = 130.0
const JUMP_VELOCITY = -350.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Player Stats
var level = 1
var xp = 0
var attack = 100
var defense = 1
var max_health = 240
var health = max_health


func _ready():
	health_bar.value = health
	

func deal_damage(damage):
	for enemy in in_attack_range:
		enemy.get_parent().take_damage(damage)
		

func take_damage(damage):
	damage = damage - defense
	health -= damage
	if health_bar:
		health_bar.value = (float(health) / max_health) * 100
	if health <= 0:
		die()
	is_recovering = false
	recover_timer.start()
	
		

func die():
	print("You died!")
	# Implement what happens when the player dies, e.g., reload the scene
	get_tree().reload_current_scene()


func _input(event):
	if event.is_action_pressed("Attack"):
		if is_attacking:
			return
		is_attacking = true
		animated_sprite.play("attack")
		await animated_sprite.animation_finished
		deal_damage(attack*5)
		is_attacking = false
		is_recovering = false
		recover_timer.start()
	if event.is_action_pressed("Dash") and dash_ready:
		if is_dashing:
			return
		animated_sprite.stop()
		
		is_dashing = true
		animated_sprite.play("dash")
		
		var original = SPEED
		SPEED = SPEED * 2.2
		
		await get_tree().create_timer(1.0).timeout
	
		dash_ready = false
		dash_timer.start()
		is_dashing = false
		SPEED = original
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.z
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input derection: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
		flip_area2d_horizontally(attack_range, false)
	elif direction < 0:
		flip_area2d_horizontally(attack_range, true)
		animated_sprite.flip_h = true
	
	if (!is_attacking && !is_dashing):
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")	
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")
		
	#Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# Function to flip the Area2D horizontally
func flip_area2d_horizontally(area: Area2D, flip: bool):
	var scale = Vector2(-1 if flip else 1, 1)
	area.scale = scale
	

func _on_attack_range_body_entered(body):
	if body is RigidBody2D && body.get_parent().has_method("take_damage"):
		in_attack_range.append(body)


func _on_attack_range_body_exited(body):
	if body is RigidBody2D && body.get_parent().has_method("take_damage"):
		in_attack_range.erase(body)


func _on_recover_timer_timeout():
	is_recovering = true
	one_second_heal.start()


func _on_one_second_heal_timeout():
	if not is_recovering:
		one_second_heal.stop()
		return
		
	if health != max_health:
		health += max_health * .05
		if health > max_health:
			health = max_health
		health_bar.value = (float(health)/max_health) * 100
	one_second_heal.start()


func _on_dash_timer_timeout():
	dash_ready = true
