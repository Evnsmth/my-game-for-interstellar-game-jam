extends Node2D

signal enemy_spawned(enemy)
signal spawning_finished


func _ready() -> void:
	await spawn_all_enemies()

func spawn_all_enemies() -> void:
	await get_tree().process_frame
	
	for spawn_point in get_children():
		if spawn_point.enemy_scene == null:
			continue
		
		var enemy = spawn_point.enemy_scene.instantiate()
		
		get_parent().add_child(enemy)
		enemy.global_position = spawn_point.global_position

		enemy_spawned.emit(enemy)
		
		await get_tree().create_timer(1.0).timeout
	
	spawning_finished.emit()
