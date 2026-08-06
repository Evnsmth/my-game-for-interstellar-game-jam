extends CharacterBody2D


@export var movement_speed = 300.0
@export var deceleration = 800.0


func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector("left", "right","up","down")
	
	# Increase velocity
	if direction:
		velocity = direction * movement_speed
	# Decrease Velcoity
	else:
		velocity.x = move_toward(velocity.x,0,deceleration * delta)
		velocity.y = move_toward(velocity.y,0,deceleration * delta)

	move_and_slide()
