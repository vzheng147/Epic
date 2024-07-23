extends Control

var isEmpty = true
var data : ItemData
@onready var use_button = $Button
@onready var menu_button = $MenuButton


func _on_menu_button_pressed():
	if not isEmpty:
		use_button.visible = !use_button.visible


func _on_button_pressed():
	print(data.attack)
