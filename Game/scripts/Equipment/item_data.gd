class_name ItemData
extends Resource

enum TYPE {WEAPON, ARMOR, RING, POTION}

@export var type : TYPE

# universal fields
@export var item_name : String
@export var item_texture : Texture2D
@export var price : int # for items in shop
@export_multiline var description : String

# data fields for equipment
@export var attack : int
@export var defense : int
@export var health : int

# data fields for potions
@export var heal_amount : int

# data fields for stones (used to upgrade equipment)
@export var success_chance : int





