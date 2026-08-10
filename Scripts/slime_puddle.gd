class_name SlimePuddle
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var floor = get_tree().get_first_node_in_group("floor")
@onready var light: PointLight2D = $PointLight2D
@onready var slime_info_ui = get_tree().get_first_node_in_group("slime_info_ui")
@onready var player = get_tree().get_first_node_in_group("player")

@export var slime_effect: SlimeEffect
@export var puddle_spacing: float = 25.0


var player_nearby: Node = null
var wobble_tween: Tween

signal puddle_consumed

func _ready() -> void:
	light.color = slime_effect.color
	start_wobble()
	if slime_effect == null:
		push_warning("This puddle has no SlimeEffect assigned.")
		return
	
	puddle_consumed.connect(floor._on_puddle_consumed)
	floor.remove_puddles.connect(_on_remove_puddles)

	sprite.texture = slime_effect.puddle_texture

	await get_tree().physics_frame
	find_free_position()

func _process(_delta: float) -> void:
	if not floor.puddle_info_unlocked:
		return
	
	if player_nearby != null and Input.is_action_just_pressed("consume"):
		consume()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = body
	
	if floor.puddle_info_unlocked and slime_info_ui != null:
		slime_info_ui.show_slime_info(slime_effect)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player_nearby:
		player_nearby = null
	
		if  slime_info_ui != null:
			slime_info_ui.hide_slime_info()

func consume():
	player_nearby.consume_slime(slime_effect)

	puddle_consumed.emit()
	RunManager.consume_puddle()

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

func start_wobble():
	wobble_tween = create_tween()
	wobble_tween.set_loops()

	wobble_tween.set_trans(Tween.TRANS_SINE)
	wobble_tween.set_ease(Tween.EASE_IN_OUT)

	wobble_tween.tween_property(
		sprite,
		"scale",
		Vector2(1.04, 0.96),
		0.6
	)

	wobble_tween.tween_property(
		sprite,
		"scale",
		Vector2(0.98, 1.02),
		0.6
	)

func _on_remove_puddles():
	if wobble_tween:
		wobble_tween.kill()

	var tween = create_tween()

	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(
		sprite,
		"scale",
		Vector2.ZERO,
		0.3
	)

	tween.tween_callback(queue_free)
