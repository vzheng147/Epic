class_name InventoryItem
extends TextureRect

@export var data : ItemData

func init(data : ItemData, size : Vector2):
	print(data)
	self.data = data
	custom_minimum_size = size
	
func _ready():
	if data:
		expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		print(data.attack)
		texture = data.item_texture
	



