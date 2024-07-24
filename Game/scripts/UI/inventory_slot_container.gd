extends Control

var isEmpty = true
var data : ItemData

@onready var use_button = $MenuButton/Button
@onready var menu_button = $MenuButton
@onready var inventoryNode = get_parent().get_parent()

func _on_menu_button_pressed():
	if not isEmpty:
		use_button.visible = !use_button.visible


func _on_button_pressed():
	match data.type: # {WEAPON, ARMOR, ACCESSORY, SPIRIT}
		0: 
			if inventoryNode.equiped[0]:
				inventoryNode.remove_item_from_equiped(0) 
			inventoryNode.add_item_to_equiped(data, 0)
		1: 	
			if inventoryNode.equiped[1]:
				inventoryNode.remove_item_from_equiped(1) 
			inventoryNode.add_item_to_equiped(data, 1)
		2: 
			if inventoryNode.equiped[2]:
				inventoryNode.remove_item_from_equiped(2) 
			inventoryNode.add_item_to_equiped(data, 2)
		3:  
			if inventoryNode.equiped[3]:
				inventoryNode.remove_item_from_equiped(3) 
			inventoryNode.add_item_to_equiped(data, 3)
	use_button.visible = false
