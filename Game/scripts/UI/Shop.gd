extends Control

@onready var shop_slot = preload("res://scenes/UI/shop_slot.tscn")

var shop = []

func _ready():
	for i in range(24):
		var slot := shop_slot.instantiate()
		%Grid.add_child(slot)
		

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
	for i in range (shop.size()):
		var item = InventoryItem.new()
		item.init(load(shop[i]), Vector2(16, 16))
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignore mouse input	
		%Grid.get_child(i).get_child(0).add_child(item)
		%Grid.get_child(i).data = item.data
		%Grid.get_child(i).index = i
		%Grid.get_child(i).isEmpty = false
	


