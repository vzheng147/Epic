extends Control

@onready var use_button := $Drop_Down_Button/Use_Button;

func _on_drop_down_button_pressed():
	use_button.visible = !use_button.visible;
	
