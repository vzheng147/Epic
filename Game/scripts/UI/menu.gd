extends Node2D



func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/World/outside.tscn")

func _on_guide_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/guide.tscn")
	

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/credits.tscn")

func _on_quit_pressed():
	get_tree().quit()

