
extends Control

# "res://scripts/Resources/potion.tres"
var equiped = [null, "res://scripts/Resources/sword.tres", null, null]
var inventory = ["res://scripts/Resources/sword.tres"]
var inventory_slot_scene = preload("res://scenes/UI/slot_container.tscn")
var equiped_slot_scene = preload("res://scenes/UI/equiped_container.tscn")

@onready var player = get_parent()
@onready var attack_label = $Attack
@onready var defense_label = $Defense
@onready var health_label = $Health
@onready var description_background = $D_background
@onready var description_label = $D_background/Description

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


func update_label():
	attack_label.text = "Attack: %s" % player.attack
	defense_label.text = "Defense: %s" % player.defense
	health_label.text = "Health: %s" % player.health

func update_description(data):
	if data:
		description_label.text = data.description
	else:
		description_label.text = ""
	

func add_item_to_equiped(equipment, index):
	# add the item and initialize data
	var item = InventoryItem.new()
	item.init(equipment, Vector2(16, 16))
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	%Equiped.get_child(index).get_child(0).add_child(item)
	%Equiped.get_child(index).data = item.data
	%Equiped.get_child(index).isEmpty = false
	
	# update equiped array
	equiped[index] = equipment
	
	# update player stats
	player.attack += equipment.attack
	player.defense += equipment.defense
	player.health += equipment.health
	
	update_label()


func remove_item_from_equiped(index):
	# remove the item and reset data
	var equipSlot = %Equiped.get_child(index)
	equipSlot.get_child(0).get_child(0).queue_free()
	equipSlot.isEmpty = true
	equipSlot.data = null
	
	# Update the equipped array
	var equipment = equiped[index]
	equiped[index] = null
	
	# Update player stats
	player.attack -= equipment.attack
	player.defense -= equipment.defense
	player.health -= equipment.health
	
	update_label()
	
	

func _input(event):
	if event.is_action_pressed("Inventory"):
		visible = !visible
