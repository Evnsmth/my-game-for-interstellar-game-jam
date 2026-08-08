extends Node2D

@onready var floor_container = $FloorContainer

var current_floor_index := 0

var floors = [
	preload("res://Scenes/Floors/floor_1.tscn"),
	preload("res://Scenes/Floors/floor_2.tscn")
]


func _ready() -> void:
	load_floor(current_floor_index)


func load_floor(index: int) -> void:
	# Make sure we actually have another floor.
	if index >= floors.size():
		return

	# Remove the current floor.
	for child in floor_container.get_children():
		child.queue_free()

	# Create the new floor.
	var new_floor = floors[index].instantiate()
	floor_container.add_child(new_floor)

	# Find THIS floor's trapdoor.
	var trapdoor = new_floor.get_node("Trapdoor")

	# Listen to THIS trapdoor.
	trapdoor.trapdoor_entered.connect(_on_trapdoor_entered)

func _on_trapdoor_entered() -> void:
	current_floor_index += 1
	load_floor(current_floor_index)
