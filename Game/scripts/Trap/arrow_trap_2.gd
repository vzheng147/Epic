extends Sprite2D

@export var damage : int
@export var flip : bool

@onready var arrowTrap = $AnimationPlayer
@onready var arrow = preload("res://scenes/Trap/arrow_2.tscn")

func _ready():
	arrowTrap.play("activate")

func shoot():
	var instance = arrow.instantiate()
	instance.dir = global_rotation + 1.57
	instance.rot = global_rotation
	instance.pos = global_position
	instance.damage = damage
	get_parent().add_child(instance)
		
