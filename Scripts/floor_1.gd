extends Node2D

@onready var enemy_spawner = $EnemySpawner
@onready var trap_door = $Trapdoor

var enemies_alive = 0
var spawning_complete := false
var floor_cleared = false


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
		clear_floor()

func clear_floor():
	if floor_cleared:
		return
	
	floor_cleared = true
	trap_door.open()
