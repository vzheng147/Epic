extends Control

@onready var player = get_parent()
@onready var shop_slot = preload("res://scenes/UI/shop_slot.tscn")
@onready var buy_button = $Buy
@onready var description = $ColorRect/Description
@onready var gold = $ColorRect2/Gold

var shop = ["res://scripts/Equipment/Weapon/worn_sword.tres"]
var selected : ItemData
var selected_index : int

func _ready():
	for i in range(24):
		var slot := shop_slot.instantiate()
		%Grid.add_child(slot)
	update_shop()
	update_gold()
		
	
func reset_shop_data():
	for i in range (24):
		var removedSlot = %Grid.get_child(i)
		if removedSlot.get_child(0).get_child(0):
			var remove = removedSlot.get_child(0).get_child(0)
			removedSlot.get_child(0).remove_child(remove)
			remove.queue_free()
			removedSlot.isEmpty = true
			removedSlot.data = null
		
func update_shop():
	for i in range (shop.size()):
		var item = InventoryItem.new()
		item.init(load(shop[i]), Vector2(16, 16))
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignore mouse input	
		%Grid.get_child(i).get_child(0).add_child(item)
		%Grid.get_child(i).data = item.data
		%Grid.get_child(i).index = i
		%Grid.get_child(i).isEmpty = false

func update_gold():
	gold.text = "Gold: %d" % player.gold

func update_description(data):
	if data:
		description.text = data.description
	else:
		description.text = ""
	
func _on_buy_pressed():
	# logic in case player cannot afford item
	if player.gold < selected.price:
		description.text = "You do not have enough gold!"
		buy_button.visible = false
		return
	
	# add bought item to inventory and update player gold
	player.inventory.inventory.append(selected.resource_path)
	player.gold = player.gold - selected.price
	
	# update player inventory visuals
	player.inventory.reset_inventory_data()
	player.inventory.update_inventory()
	player.inventory.update_label()
	
	# update the shop data and interface
	shop.remove_at(selected_index)
	reset_shop_data()
	update_shop()
	update_gold()
	update_description(null)
	buy_button.visible = false
	

