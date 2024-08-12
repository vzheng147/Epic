extends Area2D

@export var destination : NodePath
@export_multiline var description : String

@onready var player = get_parent().get_node("Player")
@onready var door = $AnimationPlayer
@onready var label = $Description

var in_range : bool = false

func _onready():
	label.text = description
	
	
func _input(event):
	if in_range and event.is_action_pressed("Interact"):
		door.play("default")
		await door.animation_finished
		get_tree().change_scene_to_file(destination)


func _on_body_entered(body):
	label.visible = true
	in_range = true
	

func _on_body_exited(body):
	label.visible = false
	in_range = false
	


