extends Area2D

@onready var arrow = $Sprite2D
@onready var life = $Life
@onready var player = get_parent().get_node("Player")
@export var SPEED = 325

var damage : int
var spawnPosition : Vector2
var flip : bool

func _ready():
	global_position = spawnPosition
	arrow.flip_h = flip
	life.start()

func _process(delta):
	if not flip:
		position += Vector2(-SPEED, 0) * delta
	if flip:
		position += Vector2(SPEED, 0) * delta

func _on_body_entered(body):
	if body.name == "Player":
		player.take_damage(damage)
	queue_free()


func _on_life_timeout():
	queue_free()
