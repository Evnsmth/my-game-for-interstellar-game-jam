extends Node2D

@onready var floor_container = $FloorContainer
@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect
@onready var player: CharacterBody2D = $Player
@onready var countdown_label: Label = $CanvasLayer/CountDownLabel
@onready var death_screen = $DeathScreen


var current_floor_index := 0
var new_floor

var floors = [
	preload("res://Scenes/Floors/floor_1.tscn"),
	preload("res://Scenes/Floors/floor_2.tscn"),
	preload("res://Scenes/Floors/floor_3.tscn"),
	preload("res://Scenes/Floors/floor_4.tscn"),
	preload("res://Scenes/Floors/floor_5.tscn"),
	preload("res://Scenes/Floors/floor_6.tscn"),
	preload("res://Scenes/Floors/floor_7.tscn"),
	preload("res://Scenes/Floors/floor_8.tscn"),
	preload("res://Scenes/Floors/floor_9.tscn"),
	preload("res://Scenes/Floors/floor_10.tscn"),
	preload("res://Scenes/Floors/floor_final.tscn")
]


func _ready() -> void:
	player.died.connect(_on_player_died)
	fade_rect.color.a = 1.0
	var first_floor = await load_floor(current_floor_index)

	player.can_control = false

	await get_tree().create_timer(0.5).timeout
	await fade_from_black()

	await run_countdown()

	print("FIRST COUNTDOWN FINISHED")

	player.can_control = true
	print("Player unfrozen")
	first_floor.start_floor()


func load_floor(index: int):
	if index >= floors.size():
		return null

	for child in floor_container.get_children():
		child.queue_free()
	
	await get_tree().process_frame

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

	var next_floor = await load_floor(current_floor_index)

	if next_floor == null:
		return

	player.can_control = false

	await get_tree().create_timer(0.5).timeout
	await fade_from_black()

	await run_countdown()

	player.can_control = true
	next_floor.start_floor()

func fade_to_black() -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.5)
	await tween.finished

func fade_from_black() -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, 0.5)
	await tween.finished

func run_countdown():
	countdown_label.show()

	countdown_label.text = "3"
	await get_tree().create_timer(0.7).timeout

	countdown_label.text = "2"
	await get_tree().create_timer(0.7).timeout

	countdown_label.text = "1"
	await get_tree().create_timer(0.7).timeout

	countdown_label.text = "GO!"
	await get_tree().create_timer(0.4).timeout

	countdown_label.hide()

func _on_player_died():
	death_screen.show_death_screen()
