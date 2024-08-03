extends Node2D



func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/World/boss_fight_arena_1.tscn")


func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/credits.tscn")

func _on_quit_pressed():
	get_tree().quit()


