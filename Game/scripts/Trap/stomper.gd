extends Area2D

@onready var stomper = $AnimationPlayer
@onready var player = get_parent().get_node("Player")

@export var damage : int

func _ready():
	stomper.play("activate")

func _on_body_entered(body):
	if body.name == "Player":
		player.take_damage(damage)
