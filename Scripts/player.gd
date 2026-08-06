extends CharacterBody2D


@export var movement_speed = 300.0
@export var deceleration = 800.0


enum State {
	MOVE,
	DASH,
	ATTACK
}

var current_state: State = State.MOVE

func _physics_process(delta: float) -> void:

	match current_state:
		
		State.MOVE:
			move_state(delta)
		
		State.DASH:
			dash_state(delta)
		
		State.ATTACK:
			attack_state(delta)

func change_state(new_state):
	current_state = new_state

func move_state(delta):

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

func dash_state(delta):
	pass

func attack_state(delta):
	pass
 
