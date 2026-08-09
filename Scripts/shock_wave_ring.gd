extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

@export var expand_speed := 100.0
@export var max_radius := 200.0

var damage : float = 25.0
var radius := 17.12
var has_been_hit = false


func _physics_process(delta):
	radius += expand_speed * delta

	collision.shape.radius = radius

	var sprite_scale = radius / 16.0
	sprite.scale = Vector2(sprite_scale, sprite_scale)

	if radius >= max_radius:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if has_been_hit == false:
		if body.has_method("get_hit"):
			has_been_hit = true
			body.get_hit(damage, global_position)
