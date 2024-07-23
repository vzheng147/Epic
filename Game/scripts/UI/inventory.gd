extends Control


func _ready():
	for i in range (30):
		var slot := InventorySlot.new()
		slot.init(itemData.TYPE.EMPTY, Vector2(32, 32))
		%Grid.add_child(slot)
	
