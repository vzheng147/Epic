extends Node2D

@onready var shop = $Control/ColorRect

var player
var in_range = false
var items : Array[String] = ["res://scripts/Equipment/Armor/standard_armor.tres",
"res://scripts/Equipment/Weapon/standard_sword.tres", "res://scripts/Equipment/Weapon/refined_sword.tres"]


func _ready():
	player = get_parent().get_node("Player")
	
func _input(event):
	if event.is_action_pressed("Interact") and in_range:
		player.shop.visible = true
		player.shop.shop = items
		player.shop.reset_shop_data()
		player.shop.update_shop()
	
	
func _on_area_2d_body_entered(body):
	if body.name == "Player":
		in_range = true


func _on_area_2d_body_exited(body):
	if body.name == "Player":
		in_range = false
		if player.shop.visible == true:
			player.shop.visible = false
			player.shop.reset_shop_data()
			items = player.shop.shop
		
	
		

	
