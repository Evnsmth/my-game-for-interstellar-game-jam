extends Node2D

@onready var floor_container = $FloorContainer
@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect
@onready var enemy_spawner = $EnemySpawner
@onready var player: CharacterBody2D = $Player


var current_floor_index := 0
var new_floor

var floors = [
	preload("res://Scenes/Floors/floor_1.tscn"),
	preload("res://Scenes/Floors/floor_2.tscn"),
	preload("res://Scenes/Floors/floor_3.tscn"),
	preload("res://Scenes/Floors/floor_4.tscn"),
	preload("res://Scenes/Floors/floor_5.tscn"),
	preload("res://Scenes/Floors/floor_6.tscn")
]


func _ready() -> void:
	fade_rect.color.a = 1.0
	var first_floor = load_floor(current_floor_index)
	await get_tree().create_timer(0.5).timeout
	await fade_from_black()
	await get_tree().create_timer(0.5).timeout
	first_floor.start_floor()


func load_floor(index: int):
	if index >= floors.size():
		return null

	for child in floor_container.get_children():
		child.queue_free()

	var next_floor = floors[index].instantiate()
	floor_container.add_child(next_floor)

	var player_spawn = next_floor.get_node("PlayerSpawn")
	player.global_position = player_spawn.global_position
	player.velocity = Vector2.ZERO

	var trapdoor = next_floor.get_node("Trapdoor")
	trapdoor.trapdoor_entered.connect(_on_trapdoor_entered)

	return next_floor

func _on_trapdoor_entered() -> void:
	transition_to_next_floor()

func transition_to_next_floor() -> void:
	await fade_to_black()

	current_floor_index += 1

	var next_floor = load_floor(current_floor_index)

	if next_floor == null:
		return

	await get_tree().create_timer(0.5).timeout

	await fade_from_black()

	await get_tree().create_timer(1.25).timeout

	next_floor.start_floor()

func fade_to_black() -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.5)
	await tween.finished

func fade_from_black() -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, 0.5)
	await tween.finished
