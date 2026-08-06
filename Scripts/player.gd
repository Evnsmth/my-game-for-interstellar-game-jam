extends CharacterBody2D

enum State {
	MOVE,
	DASH,
	ATTACK
}

#region Constants
const BULLET_SCENE = preload("res://Scenes/bullet.tscn")
#endregion

#region Onready Variables
@onready var aim_pivot: Node2D = $AimPivot
#endregion

#region Export Variables
@export var movement_speed = 300.0
@export var deceleration = 800.0
@export var dash_time = 0.15
@export var dash_speed = 800.0
#endregion

#region Member Variables
var current_state: State = State.MOVE
var dash_timer = 0.0
var dash_direction = Vector2.ZERO
#endregion

func _process(delta: float) -> void:
	aim_pivot.look_at(get_global_mouse_position())


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
	
	if current_state == State.DASH:
		dash_timer = dash_time
		dash_direction = Input.get_vector("left","right","up","down")

func move_state(delta):

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector("left", "right","up","down")
	
	#Check if dash was pressed
	if(Input.is_action_just_pressed("dash")):
		change_state(State.DASH)
	
	if(Input.is_action_just_pressed("shoot")):
		shoot()
	
	# Increase velocity
	if direction:
		velocity = direction * movement_speed
	# Decrease Velcoity
	else:
		velocity.x = move_toward(velocity.x,0,deceleration * delta)
		velocity.y = move_toward(velocity.y,0,deceleration * delta)
	

	move_and_slide()

func dash_state(delta):

	velocity = dash_direction * dash_speed

	move_and_slide()

	dash_timer -= delta

	if(dash_timer <0):
		change_state(State.MOVE)

func attack_state(delta):
	pass
 
func shoot():
	var bullet = BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = $AimPivot/BulletSpawn.global_position
	bullet.direction = global_position.direction_to(get_global_mouse_position())
	bullet.rotation = bullet.direction.angle() + deg_to_rad(90)
