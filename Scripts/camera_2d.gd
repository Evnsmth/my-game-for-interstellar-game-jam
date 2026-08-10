extends Camera2D

@export var shake_fade := 5.0

var shake_strength := 0.0

func _process(delta):
	if shake_strength > 0:
		shake_strength = move_toward(
			shake_strength,
			0,
			shake_fade * delta
		)

		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		offset = Vector2.ZERO


func shake(strength: float):
	print("SHAKE CALLED: ", strength)
	shake_strength = strength
