extends CharacterBody2D
#this is the script that will move around our character 
@onready var flash_animation = $FlashAnimation
@onready var health_bar = $HealthBar

const SPEED = 130.0
const JUMP_VELOCITY = -350.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Health variables and functions

var max_health = 100
var health = max_health
var hp = 100

func _ready():
	if health_bar:
		health_bar.value = hp
	
func _on_add_health_pressed():
	hp += 10
	if health_bar:
		health_bar.value = hp
	
func _on_subtract_health_pressed():
	hp -= 10
	if health_bar:
		health_bar.value = hp
	flash_animation.play("flash") #play flash effect

func take_damage(damage):
	_on_subtract_health_pressed()
	health -= damage
	print(health)
	if (hp <= 0):
		die()
		

func die():
	print("You died!")
	get_tree().reload_current_scene()

@onready var animated_sprite = $AnimatedSprite2D


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
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# Play animations 
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
