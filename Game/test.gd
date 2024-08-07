extends CharacterBody2D

@onready var sprite = $Sprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var pos : Vector2
var rot : float
var dir : float

func _ready():
	sprite.global_position = pos
	sprite.global_rotation = rot

func _physics_process(delta):
	print(sprite.global_rotation)
	
	velocity = Vector2(0, SPEED).rotated(sprite.global_rotation)

	move_and_slide()
