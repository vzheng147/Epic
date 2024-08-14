extends Node2D

@onready var exit = $Exit

@export var destination : String


func _on_exit_pressed():
	get_tree().change_scene_to_file(destination)
