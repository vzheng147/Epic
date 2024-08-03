extends Area2D

@onready var player = get_parent().get_node("Player")
@onready var spear = $AnimationPlayer

@export var damage : int

func _ready():
	spear.play("activate")
	
	
func _on_body_entered(body):
	if body.name == "Player":
		player.take_damage(damage)
