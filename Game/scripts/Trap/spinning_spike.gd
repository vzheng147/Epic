extends StaticBody2D

@onready var spike = $AnimationPlayer
@onready var timer = $Damage_Timer
@onready var player = get_parent().get_node("Player")

@export var damage : int

var in_range = false

func _ready():
	spike.play("activate")


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player.take_damage(damage)
		in_range = true
		timer.start()	


func _on_area_2d_body_exited(body):
	in_range = false
	timer.stop()
	

# Player takes continously damage if staying within spike range

func _on_damage_timer_timeout():
	if in_range:
		player.take_damage(damage)
		timer.start()
