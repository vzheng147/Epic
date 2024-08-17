extends Node2D

@onready var exit = $Exit
@onready var defeat = $Defeat

@export var drop : ItemData
var back := "res://scenes/World/floor_5.tscn"
var destination := "res://scenes/World/outside.tscn"
var door := preload("res://scenes/World/door.tscn")
var chest := preload("res://scenes/Collectables/golden_chest.tscn")


func boss_death():
	var door_instance = door.instantiate()
	door_instance.destination = destination
	door_instance.global_position = Vector2(0, -190)
	add_child(door_instance)
	defeat.visible = true

	
func _on_exit_pressed():
	get_tree().change_scene_to_file(back)
