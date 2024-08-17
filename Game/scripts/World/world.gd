extends Node2D

@onready var player = $Player

func _ready():
	if Global.player_position:
		player.global_position = Global.player_position
	
	
func spawn(minion, sight_range, spawn_location, spawn_time, attack, defense, health, xp, gold):
	
	# Instantiate the minion at a set location
	var instance = load(minion)
	var spawn = instance.instantiate()
	spawn.respawn_location = spawn_location
	spawn.sight_range = sight_range
	spawn.respawn_time = spawn_time
	spawn.attack = attack
	spawn.defense = defense
	spawn.max_health = health
	spawn.xp = xp
	spawn.gold = gold
	
	# One-time-use timer that gets queue_free() after timeout
	await get_tree().create_timer(spawn_time).timeout
	
	# Respawn the minion
	add_child(spawn)
	


