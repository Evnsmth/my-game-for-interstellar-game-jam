extends Area2D


var damage: float = 10.0
@export var speed = 100.0

var direction = Vector2.ZERO


func _physics_process(delta: float) -> void:
	position += direction * speed * delta

# Deals damage to enemies
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("get_hit"):
		body.get_hit(damage, global_position)
	queue_free()
