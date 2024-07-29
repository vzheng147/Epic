extends Node2D


@onready var shop = $Control/ColorRect
var player
var in_range = false


func _onready():
	player = get_parent().get_node("Player")
	
func _input(event):
	if event.is_action_pressed("Interact") and in_range:
		print("Interact!")
	
	
func _on_area_2d_body_entered(body):
	in_range = true


func _on_area_2d_body_exited(body):
	in_range = false
