class_name SlimePuddle
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var floor = get_tree().get_first_node_in_group("floor")

@export var slime_effect: SlimeEffect
@export var puddle_spacing: float = 25.0


var player_nearby: Node = null

signal puddle_consumed

func _ready() -> void:
	if slime_effect == null:
		push_warning("This puddle has no SlimeEffect assigned.")
		return
	
	puddle_consumed.connect(floor._on_puddle_consumed)
	floor.remove_puddles.connect(_on_remove_puddles)

	sprite.texture = slime_effect.puddle_texture

	await get_tree().physics_frame
	find_free_position()

func _process(_delta: float) -> void:
	if player_nearby != null and Input.is_action_just_pressed("consume"):
		consume()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player_nearby:
		player_nearby = null

func consume():
	player_nearby.apply_slime_effect(slime_effect)
	
	print("Consumed: ", slime_effect.effect_name)
	
	puddle_consumed.emit()
	
	queue_free()

func find_free_position() -> void:
	var attempts := 0
	var max_attempts := 20

	while is_too_close_to_another_puddle() and attempts < max_attempts:
		global_position += Vector2(
			randf_range(-puddle_spacing, puddle_spacing),
			randf_range(-puddle_spacing, puddle_spacing)
		)

		attempts += 1

func is_too_close_to_another_puddle() -> bool:
	var puddles = get_tree().get_nodes_in_group("puddle")

	for puddle in puddles:
		if puddle == self:
			continue

		var distance = global_position.distance_to(puddle.global_position)

		if distance < puddle_spacing:
			return true

	return false

func _on_remove_puddles():
	queue_free()
