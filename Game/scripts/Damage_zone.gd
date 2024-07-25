extends Node2D

const SPEED = 60
@export var damage_amount = 10

var direction = 1
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D

func _ready():
	# Ensure that all required nodes are properly found
	if ray_cast_right and ray_cast_left and animated_sprite and area:
		print("All nodes found successfully")
		# Connect the body_entered signal to the _on_body_entered method
		area.body_entered.connect(Callable(self, "_on_body_entered"))
		print("Signal connected")
	else:
		print("Error: One or more nodes not found")

func _process(delta):
	if ray_cast_right and ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	elif ray_cast_left and ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	position.x += direction * SPEED * delta

func _on_body_entered(body):
	print("Body entered function called")
	if body.is_in_group("Player"):  # Check if the entered body is the player
		print("Player collided with the slime!")
		body.take_damage(damage_amount)
	else:
		print("Non-player body entered")
