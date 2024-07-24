
extends Control

var equiped = [null, "res://scripts/Resources/potion.tres", null, null]
var inventory = ["res://scripts/Resources/sword.tres"]
var inventory_slot_scene = preload("res://scenes/UI/slot_container.tscn")
var equiped_slot_scene = preload("res://scenes/UI/equiped_container.tscn")


func _ready():
	# initializing equiped
	for i in range (4):
		var slot := equiped_slot_scene.instantiate()
		%Equiped.add_child(slot)
	for i in range (4):
		if equiped[i]:
			add_item_to_equiped(load(equiped[i]), i)
			
	# initializing inventory
	for i in range (24):
		var slot := inventory_slot_scene.instantiate()
		%Grid.add_child(slot)
	for i in range (inventory.size()):
		var item = InventoryItem.new()
		item.init(load(inventory[i]), Vector2(16, 16))
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignore mouse input	
		%Grid.get_child(i).get_child(0).add_child(item)
		%Grid.get_child(i).data = item.data
		%Grid.get_child(i).isEmpty = false


func add_item_to_equiped(equipment, index):
	var item = InventoryItem.new()
	item.init(equipment, Vector2(16, 16))
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	%Equiped.get_child(index).get_child(0).add_child(item)
	%Equiped.get_child(index).data = item.data
	%Equiped.get_child(index).isEmpty = false
	equiped[index] = equipment

func remove_item_from_equiped(index):
	var equipSlot = %Equiped.get_child(index)
	equipSlot.get_child(0).get_child(0).queue_free()
	equipSlot.isEmpty = true
	equipSlot.data = null
	
	# Update the equipped array
	print(equiped[index])
	equiped[index] = null

func _input(event):
	if event.is_action_pressed("Inventory"):
		visible = !visible
