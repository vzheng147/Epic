extends CharacterBody2D

@onready var arrow = $Sprite2D
@onready var life = $Life
@onready var player = get_parent().get_node("Player")
@export var SPEED = 325

var damage : int
var pos : Vector2
var rot : float
var dir : float

func _ready():
	arrow.global_position = pos
	arrow.global_rotation = rot
	life.start()

func _physics_process(delta):
	
	velocity = Vector2(0, SPEED).rotated(dir)

	move_and_slide()


func _on_life_timeout():
	queue_free()


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player.take_damage(damage)
		queue_free()
