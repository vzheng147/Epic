extends Node2D

@onready var exit = $Exit

@export var drop : ItemData
var back := "res://scenes/World/floor_4.tscn"
var destination := "res://scenes/World/floor_5.tscn"
var door := preload("res://scenes/World/door.tscn")
var chest := preload("res://scenes/Collectables/golden_chest.tscn")


func boss_death():
	var door_instance = door.instantiate()
	door_instance.destination = destination
	door_instance.global_position = Vector2(25, 34)
	add_child(door_instance)
	var chest_instance = chest.instantiate()
	chest_instance.drop = drop
	chest_instance.global_position = Vector2(-25, 23.5)
	Global.player_position = Vector2(0, 0)
	add_child(chest_instance)
	
	
func _on_exit_pressed():
	Global.player_position = Vector2(1168, 250)
	get_tree().change_scene_to_file(back)