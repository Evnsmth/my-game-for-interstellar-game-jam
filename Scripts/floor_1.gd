extends Node2D

signal remove_puddles

@onready var enemy_spawner = $EnemySpawner
@onready var trapdoor = $Trapdoor

var enemies_alive = 0
var spawning_complete := false
var floor_cleared = false
var puddle_info_unlocked := false
var consumption_complete = false


func _ready():
	enemy_spawner.enemy_spawned.connect(_on_enemy_spawned)
	enemy_spawner.spawning_finished.connect(_on_spawning_finished)


func _on_enemy_spawned(enemy):
	enemies_alive += 1
	enemy.died.connect(_on_enemy_died)

func _on_enemy_died():
	enemies_alive -= 1
	check_floor_clear()

func _on_spawning_finished():
	spawning_complete = true
	check_floor_clear()

func check_floor_clear():
	if spawning_complete and enemies_alive <= 0:
		puddle_info_unlocked = true

		if consumption_complete:
			clear_floor()

func clear_floor():
	if floor_cleared:
		return
	
	floor_cleared = true
	trapdoor.open()

func _on_puddle_consumed() -> void:
	consumption_complete = true
	remove_puddles.emit()
	check_floor_clear()
