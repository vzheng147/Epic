extends Node

class_name SaveManager

const SAVE_PATH = "res://scripts/save.tres"

var data : PlayerData
var saved_scene : String

var level : int
var xp : int
var total_xp : int
var gold : int

var attack : int
var defense : int
var max_health : int

var inventory : Array
var equiped : Array


func save_game(player, inventory):
	data = PlayerData.new()
	data.level = player.level
	data.xp = player.xp
	data.total_xp = player.total_xp
	data.gold = player.gold
	
	data.attack = player.attack
	data.defense = player.defense
	data.max_health = player.max_health
	
	data.inventory = inventory.inventory
	data.equiped = inventory.equiped
	
	data.scene = get_tree().current_scene.scene_file_path
	
	ResourceSaver.save(data, SAVE_PATH)
	
	
	
func load_game():
	if ResourceLoader.exists(SAVE_PATH):
		var saved_data = ResourceLoader.load(SAVE_PATH)
		
		level = saved_data.level
		xp = saved_data.xp
		total_xp = saved_data.total_xp
		gold = saved_data.gold
		
		attack = saved_data.attack
		defense = saved_data.defense
		max_health = saved_data.max_health
		
		inventory = saved_data.inventory
		equiped = saved_data.equiped
		
		saved_scene = saved_data.scene
		
