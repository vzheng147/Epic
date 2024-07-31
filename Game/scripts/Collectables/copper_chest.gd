extends Node2D


@onready var chest = $chest_sprite
@onready var player = get_parent().get_node("Player")
@export var drop = ItemData

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		chest.play("open_chest")
		await chest.animation_finished
		player.inventory.inventory.append(drop.resource_path)
		player.inventory.reset_inventory_data()
		player.inventory.update_inventory()
		queue_free()
