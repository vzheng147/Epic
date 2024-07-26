extends Node2D

@onready var chest = $chest_sprite
@export var drop : ItemData

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		chest.play("open_chest")
		await chest.animation_finished
		queue_free()

