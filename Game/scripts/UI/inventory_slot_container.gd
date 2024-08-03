extends Control

var isEmpty = true
var data : ItemData
var index : int

@onready var menu_button = $MenuButton
@onready var inventoryNode = get_parent().get_parent()

	
func _on_menu_button_pressed():
	if not isEmpty:
		inventoryNode.equip_button.visible = !inventoryNode.equip_button.visible
		inventoryNode.discard_button.visible = !inventoryNode.discard_button.visible
		inventoryNode.selected_index = index
		inventoryNode.selected = data
		inventoryNode.update_description(data)


