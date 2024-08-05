extends Sprite2D

@export var damage : int
@export var flip : bool

@onready var arrowTrap = $AnimationPlayer
@onready var arrow = preload("res://scenes/Trap/arrow_1.tscn")

func _ready():
	arrowTrap.play("activate")

func shoot():
	var instance = arrow.instantiate()
	instance.flip = flip
	instance.damage = damage
	instance.spawnPosition = global_position
	get_parent().add_child(instance)
		
