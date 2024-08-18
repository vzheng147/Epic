extends Control

var isEmpty = true
var data : ItemData
var index : int

@onready var menu_button = $MenuButton
@onready var shop_node = get_parent().get_parent()


func _on_menu_button_pressed():
	if not isEmpty:
		shop_node.buy_button.visible = !shop_node.buy_button.visible
		shop_node.selected_index = index
		shop_node.selected = data
		shop_node.update_price()
		shop_node.cost_container.visible = !shop_node.cost_container.visible
		shop_node.update_description(data)
