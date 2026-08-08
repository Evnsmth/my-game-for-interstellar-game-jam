extends Node2D

signal enemy_spawned(enemy)
signal spawning_finished



func start_spawning() -> void:
	await get_tree().process_frame
	
	# Spawns the chosen enemy at each given spawn point
	for spawn_point in get_children():
		if spawn_point.enemy_scene == null:
			continue
		
		var enemy = spawn_point.enemy_scene.instantiate()
		
		get_parent().add_child(enemy)
		enemy.global_position = spawn_point.global_position

		enemy_spawned.emit(enemy)
		
	
	spawning_finished.emit()
