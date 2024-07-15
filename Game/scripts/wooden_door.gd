extends Node2D

@onready var door = $door_sprite


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		door.play("opening")
		await door.animation_finished
		# get_tree().change_scene_to_file("")
