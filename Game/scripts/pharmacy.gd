extends Node2D

@export var items : Array[Resource]

@onready var shop = $Control/ColorRect

var player
var in_range = false
var items_resource_paths : Array[String]

func _ready():
	player = get_parent().get_node("Player")
	
func _input(event):
	if event.is_action_pressed("Interact") and in_range:
		convert_items_to_resource_path()
		player.shop.visible = true
		player.shop.shop = items_resource_paths
		player.shop.reset_shop_data()
		player.shop.update_shop()
	
	
func _on_area_2d_body_entered(body):
	in_range = true


func _on_area_2d_body_exited(body):
	in_range = false
	player.shop.visible = false
	player.shop.reset_shop_data()
	print(items_resource_paths.size())
	items_resource_paths = player.shop.shop
	print(items_resource_paths.size())
	convert_resource_path_to_items()
	
	
func convert_items_to_resource_path():
	items_resource_paths.clear()
	for item in items:
		items_resource_paths.append(item.resource_path)
		
func convert_resource_path_to_items():
	items.clear()
	for path in items_resource_paths:
		items.append(load(path))
		

	
