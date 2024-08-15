extends Area2D

@onready var player = get_parent().get_node("Player")



func _on_body_entered(body):
	if body.name == "Player":
		await get_tree().create_timer(.25).timeout
		player.die()
