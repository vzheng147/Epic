extends Control


func _ready():
	for i in range (30):
		var slot := InventorySlot.new()
		slot.init(itemData.TYPE.EMPTY, Vector2(16, 16))
		%Grid.add_child(slot)
	

func _input(event):
	if event.is_action_pressed("Inventory"):
		visible = !visible
