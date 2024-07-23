extends Control

var inventory_slot_scene = preload("res://scenes/UI/slot_container.tscn")
var slot_size = Vector2(16, 16)

func _ready():
	for i in range (24):
		var slot := inventory_slot_scene.instantiate()
		%Grid.add_child(slot)
	

func _input(event):
	if event.is_action_pressed("Inventory"):
		visible = !visible
