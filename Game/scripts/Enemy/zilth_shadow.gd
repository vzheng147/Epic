extends CharacterBody2D

const SPEED = 190.00

@onready var life = $Life
@onready var sprite = $AnimatedSprite2D
@onready var damage_zone = $Area2D
@onready var player = get_parent().get_node("Player")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var damage : float
var spawnPosition : Vector2
var flip : bool

func _ready():
	global_position = spawnPosition
	sprite.flip_h = flip
	life.start()
	

func _process(delta):
	if sprite.flip_h == false:
		position += Vector2(SPEED, 0) * delta
		flip_area2d_horizontally(damage_zone, false)
	if sprite.flip_h == true:
		position += Vector2(-SPEED, 0) * delta
		flip_area2d_horizontally(damage_zone, true)
	move_and_slide()

# Function to flip the Area2D horizontally
func flip_area2d_horizontally(area: Area2D, flip: bool):
	var scale = Vector2(-1 if flip else 1, 1)
	area.scale = scale
	

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player.take_damage(damage)


func _on_life_timeout():
	queue_free()
