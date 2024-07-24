extends Control

var equiped = [null, "res://scripts/Resources/sword.tres", null, null]
var inventory = ["res://scripts/Resources/sword.tres"]
var inventory_slot_scene = preload("res://scenes/UI/slot_container.tscn")

func _ready():
	# initializing equiped
	for i in range (4):
		var slot := inventory_slot_scene.instantiate()
		%Equiped.add_child(slot)
	for i in range (4):
		if equiped[i]:
			var item = InventoryItem.new()
			item.init(load(equiped[i]), Vector2(46, 46))
			item.mouse_filter = Control.MOUSE_FILTER_IGNORE
			%Equiped.get_child(i).add_child(item)
			%Equiped.get_child(i).data = item.data
			%Equiped.get_child(i).isEmpty = false
	# initializing inventory
	for i in range (24):
		var slot := inventory_slot_scene.instantiate()
		%Grid.add_child(slot)
	for i in inventory.size():
		var item = InventoryItem.new()
		item.init(load(inventory[i]), Vector2(46, 46))
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignore mouse input	
		%Grid.get_child(i).add_child(item)
		%Grid.get_child(i).data = item.data
		%Grid.get_child(i).isEmpty = false
	

func _input(event):
	if event.is_action_pressed("Inventory"):
		visible = !visible
