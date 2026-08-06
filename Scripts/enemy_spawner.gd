extends Node2D

@export var enemy_scene: PackedScene

func _ready() -> void:
	await spawn_all_enemies()

func spawn_all_enemies() -> void:
	await get_tree().process_frame
	
	for spawn_point in get_children():
		print(
			"Spawning ",
			spawn_point.name,
			" at ",
			spawn_point.global_position
		)
		var enemy = enemy_scene.instantiate()

		get_parent().add_child(enemy)
		enemy.global_position = spawn_point.global_position

		await get_tree().create_timer(1.0).timeout
