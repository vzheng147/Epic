class_name InventorySlot
extends PanelContainer

@export var type : itemData.TYPE

func init(t: itemData.TYPE, cms: Vector2):
	type = t
	custom_minimum_size = cms

	
