extends Area2D

@export var damage: float = 10.0
@export var speed = 700.0

var direction = Vector2.ZERO


func _physics_process(delta: float) -> void:
	position += direction * speed * delta

# Deals damage to enemies
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
