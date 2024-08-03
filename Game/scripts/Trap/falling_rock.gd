extends StaticBody2D

@onready var rock = $AnimationPlayer
@onready var respawn_timer = $Respawn

func _on_detection_body_entered(body):
	if body.name == "Player":
		rock.play("collapse")
		await rock.animation_finished
		respawn_timer.start()


func _on_respawn_timeout():
	rock.play("RESET")
