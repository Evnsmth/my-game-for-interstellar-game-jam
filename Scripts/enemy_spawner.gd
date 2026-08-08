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
		enemy.add_to_group("enemy")
		
		get_parent().add_child(enemy)
		enemy.global_position = spawn_point.global_position

		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		enemy_spawned.emit(enemy)

	spawning_finished.emit()
