extends CharacterBody2D
#this is the script that will move around our character 
@onready var inventory = $Inventory
@onready var flash_animation = $FlashAnimation
@onready var health_bar = $HealthBar

const SPEED = 130.0
const JUMP_VELOCITY = -350.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking = false

# Player Stats
var level = 1
var xp = 0
var attack = 5
var defense = 1
var health = 100


func _ready():
	health_bar.value = health
	
	
func _on_add_health_pressed():
	health += 10
	health_bar.value = health
	
func _on_subtract_health_pressed():
	health -= 10
	health_bar.value = health
	flash_animation.play("flash") #play flash effect

func take_damage(damage):
	health -= damage
	if health_bar:
		health_bar.value = health
	if health <= 0:
		die()
		

func die():
	print("You died!")
	# Implement what happens when the player dies, e.g., reload the scene
	get_tree().reload_current_scene()

@onready var animated_sprite = $AnimatedSprite2D

func _input(event):
	if event.is_action_pressed("Attack"):
		is_attacking = true
		print("ATTACK")
		animated_sprite.play("attack")
		await animated_sprite.animation_finished
		is_attacking = false
		
	
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
	
	if (!is_attacking):
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

