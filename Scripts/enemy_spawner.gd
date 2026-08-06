extends Node2D

signal enemy_spawned(enemy)
signal spawning_finished

@export var enemy_scene: PackedScene

func _ready() -> void:
	await spawn_all_enemies()

func spawn_all_enemies() -> void:
	await get_tree().process_frame
	
	for spawn_point in get_children():
		var enemy = enemy_scene.instantiate()
		get_parent().add_child(enemy)
		enemy.global_position = spawn_point.global_position

		enemy_spawned.emit(enemy)
		await get_tree().create_timer(1.0).timeout
	
	spawning_finished.emit()
