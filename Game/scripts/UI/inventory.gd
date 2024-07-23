extends Control

var inventory = ["res://scripts/Resources/sword.tres"]
var inventory_slot_scene = preload("res://scenes/UI/slot_container.tscn")

func _ready():
	for i in range (24):
		var slot := inventory_slot_scene.instantiate()
		%Grid.add_child(slot)
	for i in inventory.size():
		var item = InventoryItem.new()
		item.init(load(inventory[i]), Vector2(36, 36))
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignore mouse input	
		%Grid.get_child(i).add_child(item)
		%Grid.get_child(i).data = item.data
		%Grid.get_child(i).isEmpty = false
	

func _input(event):
	if event.is_action_pressed("Inventory"):
		visible = !visible
