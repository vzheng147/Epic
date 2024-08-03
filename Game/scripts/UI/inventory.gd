
extends Control


var equiped = [null, null, null]
var inventory = ["res://scripts/Equipment/Armor/refined_armor.tres", "res://scripts/Equipment/Ring/ring_of_cyclops.tres",
"res://scripts/Equipment/Weapon/dragonslayer.tres", "res://scripts/Equipment/Weapon/shadowborne.tres",
"res://scripts/Potions/Potions_Of_Vitality/large_potion_of_vitality.tres", "res://scripts/Potions/Potions_Of_Vitality/medium_potion_of_vitality.tres",
"res://scripts/Potions/Potions_Of_Vitality/small_potion_of_vitality.tres", "res://scripts/Potions/Potions_Of_Strength/large_potion_of_strength.tres",
"res://scripts/Potions/Potions_Of_Strength/medium_potion_of_strength.tres", "res://scripts/Potions/Potions_Of_Strength/small_potion_of_strength.tres",
"res://scripts/Potions/Potions_Of_Fortitude/large_potion_of_fortitude.tres", "res://scripts/Potions/Potions_Of_Fortitude/medium_potion_of_fortitude.tres",
"res://scripts/Potions/Potions_Of_Fortitude/small_potion_of_fortitude.tres"]
var inventory_slot_scene = preload("res://scenes/UI/slot_container.tscn")
var equiped_slot_scene = preload("res://scenes/UI/equiped_container.tscn")
var selected : ItemData = null
var selected_index : int

@onready var player = get_parent()
@onready var level_label = $Stats/Level 
@onready var xp_label = $Stats/XP
@onready var attack_label = $Stats/Attack
@onready var defense_label = $Stats/Defense
@onready var health_label = $Stats/Health
@onready var gold_label = $Stats/Gold
@onready var description_background = $D_background
@onready var description_label = $D_background/Description
@onready var equip_button = $Use
@onready var discard_button = $Discard

func _ready():
	# initializing equiped
	for i in range (3):
		var slot := equiped_slot_scene.instantiate()
		%Equiped.add_child(slot)
	for i in range (3):
		if equiped[i]:
			add_item_to_equiped(load(equiped[i]), i)
			
	# initializing inventory
	for i in range (24):
		var slot := inventory_slot_scene.instantiate()
		%Grid.add_child(slot)
	update_inventory()

func reset_inventory_data():
	for i in range (24):
		var removedSlot = %Grid.get_child(i)
		if removedSlot.get_child(0).get_child(0):
			var remove = removedSlot.get_child(0).get_child(0)
			removedSlot.get_child(0).remove_child(remove)
			remove.queue_free()
			removedSlot.isEmpty = true
			removedSlot.data = null
		
func update_inventory():

	for i in range (inventory.size()):
		var item = InventoryItem.new()
		item.init(load(inventory[i]), Vector2(16, 16))
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignore mouse input	
		%Grid.get_child(i).get_child(0).add_child(item)
		%Grid.get_child(i).data = item.data
		%Grid.get_child(i).index = i
		%Grid.get_child(i).isEmpty = false

func update_label():
	level_label.text = "Level: %d" % player.level
	gold_label.text = "Gold: %d" % player.gold
	attack_label.text = "Attack: %d" % player.attack
	defense_label.text = "Defense: %d" % player.defense
	health_label.text = "Health: %d" % player.max_health
	
	if player.level < 30:
		xp_label.text = "XP: %d / %d" % [player.xp, player.total_xp]
	else:
		xp_label.text = "Max Level"

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
	player.max_health += equipment.health
	


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
	player.max_health -= equipment.health
	
	update_label()
	
	

func _input(event):
	if event.is_action_pressed("Inventory"):
		visible = !visible
	

func _on_use_pressed():
	match selected.type: # {WEAPON, ARMOdR, ACCESSORY}
		0: 
			if equiped[0]:
				remove_item_from_equiped(0) 
			add_item_to_equiped(selected, 0)
		1: 	
			if equiped[1]:
				remove_item_from_equiped(1) 
			add_item_to_equiped(selected, 1)
		2: 
			if equiped[2]:
				remove_item_from_equiped(2) 
			add_item_to_equiped(selected, 2)
		3:
			player.attack += selected.attack
			player.defense += selected.defense
			player.health += selected.health
			player.max_health += selected.health
			
			inventory.remove_at(selected_index)
			reset_inventory_data()
			update_inventory()
			
			
	update_description(null)
	update_label()
	equip_button.visible = false
	discard_button.visible = false



func _on_discard_pressed():
	
	# store the item to check for item in equiped
	var removed = load(inventory[selected_index])
	inventory.remove_at(selected_index)

	# remove the item visually and reset data
	reset_inventory_data()
	# add all items back to inventory
	update_inventory()
	
	# remove the item from equiped
	for i in range (3):
		if removed == equiped[i]:
			remove_item_from_equiped(i)
	
	update_description(null)
	equip_button.visible = false
	discard_button.visible = false
			
	
	
