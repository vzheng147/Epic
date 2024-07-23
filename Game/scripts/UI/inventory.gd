extends Control

var inventory_slot_scene = preload("res://scenes/UI/slot_container.tscn")
var slot_size = Vector2(16, 16)

func _ready():
	for i in range (24):
		var slot := inventory_slot_scene.instantiate()
		%Grid.add_child(slot)
	for i in range (24):
		var color_rect = ColorRect.new()
		color_rect.custom_minimum_size = Vector2(36, 36)
		color_rect.color = Color(0.784, 0.784, 0.784, 0.392)
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignore mouse input
		
		%Grid.get_child(i).add_child(color_rect)
	

func _input(event):
	if event.is_action_pressed("Inventory"):
		visible = !visible
