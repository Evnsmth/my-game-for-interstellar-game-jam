class_name SlimePuddle
extends Node2D

@export var slime_effect: SlimeEffect

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if slime_effect == null:
		push_warning("This puddle has no SlimeEffect assigned.")
		return

	sprite.texture = slime_effect.puddle_texture

	print("Spawned puddle containing: ", slime_effect.effect_name)
