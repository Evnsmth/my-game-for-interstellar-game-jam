class_name SlimePuddle
extends Node2D

@onready var floor = get_tree().get_first_node_in_group("floor")

@export var slime_effect: SlimeEffect

@onready var sprite: Sprite2D = $Sprite2D

var player_nearby: Node = null

signal puddle_consumed

func _ready() -> void:
	if slime_effect == null:
		push_warning("This puddle has no SlimeEffect assigned.")
		return
	
	puddle_consumed.connect(floor._on_puddle_consumed)
	floor.remove_puddles.connect(_on_remove_puddles)

	sprite.texture = slime_effect.puddle_texture

	print("Spawned puddle containing: ", slime_effect.effect_name)

func _process(delta: float) -> void:
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

func _on_remove_puddles():
	queue_free()
