extends Area2D

@onready var game_manager = %GameManager
@onready var animation_player = $AnimationPlayer

func _on_body_entered(body):
	game_manager.add_HRB()
	animation_player.play("puckupHRB")#remove coin from the scene
