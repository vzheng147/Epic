extends Control

var isEmpty = true
var data : ItemData

@onready var use_button = $MenuButton/Button
@onready var menu_button = $MenuButton
@onready var inventoryNode = get_parent().get_parent()

func _on_menu_button_pressed():
	if not isEmpty:
		use_button.visible = !use_button.visible
		inventoryNode.update_description(data)


func _on_button_pressed():
	match data.type: # {WEAPON, ARMOR, ACCESSORY, SPIRIT}
		0: inventoryNode.remove_item_from_equiped(0)
		1: inventoryNode.remove_item_from_equiped(1)
		2: inventoryNode.remove_item_from_equiped(2)
		3: inventoryNode.remove_item_from_equiped(3)
	use_button.visible = false
	inventoryNode.update_description(null)
