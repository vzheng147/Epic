extends CharacterBody2D

@export var SPEED = 270.0

@onready var life = $Life
@onready var sprite = $Sprite

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
	if sprite.flip_h == true:
		position += Vector2(-SPEED, 0) * delta
	move_and_slide()


func _on_life_timeout():
	queue_free()


func _on_damage_zone_body_entered(body):
	if body is RigidBody2D && body.get_parent().has_method("take_damage"):
		body.get_parent().take_damage(damage)
		queue_free()
