extends Control

@onready var use_button = $Button
@onready var menu_button = $MenuButton


func _on_menu_button_pressed():
	use_button.visible = !use_button.visible
