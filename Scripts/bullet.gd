extends Area2D

var direction = Vector2.ZERO
var speed = 1000.0

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
