extends Node2D


func spawn(minion, sight_range, spawn_location, spawn_time):
	
	# Instantiate the minion at a set location
	var instance = load(minion)
	var spawn = instance.instantiate()
	spawn.respawn_location = spawn_location
	spawn.sight_range = sight_range
	
	# One-time-use timer that gets queue_free() after timeout
	await get_tree().create_timer(spawn_time).timeout
	
	# Respawn the minion
	add_child(spawn)
	


