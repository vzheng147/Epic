extends StaticBody2D


@onready var projectile = preload("res://test.tscn")
@onready var sprite = $Sprite2D

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(sprite.global_rotation)
	var instance = projectile.instantiate()
	instance.pos = sprite.global_position
	instance.rot = sprite.global_rotation
	instance.dir = global_rotation
	get_parent().add_child(instance)
