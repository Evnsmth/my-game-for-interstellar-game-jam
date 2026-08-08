extends CharacterBody2D


enum State {
	MOVE,
	DASH,
	KNOCKBACK,
	DEAD
}

#region Constants
const BULLET_SCENE = preload("res://Scenes/bullet.tscn")
#endregion

#region Onready Variables
@onready var aim_pivot: Node2D = $AimPivot
@onready var shoot_timer: Timer = $ShootTimer
@onready var health_label: Label = $HealthLabel
@onready var dash_label: Label = $DashLabel
#endregion

#region Stat Related Variables
# Base Stats used for calculation
@export_category("Base Stats")
@export var base_max_health : float = 100.0
@export var base_movement_speed : float = 150.0
@export var base_damage : float = 10.0
@export var base_fire_rate : float = 1.0

# The stats used post stat calculation
var movement_speed: float
var damage: float
var fire_rate: float
var max_health: float

var current_health : float

# Stores all slime effects
var consumed_effects: Array[SlimeEffect] = []
#endregion


@export var deceleration = 1200.0
@export var dash_time = 0.1
@export var dash_cooldown_time = 1.0
@export var dash_speed = 400.0
@export var knockback_speed := 300.0
@export var knockback_time := 0.125

var current_state: State = State.MOVE
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var can_dash = true
var dash_direction = Vector2.ZERO
var knockback_direction := Vector2.ZERO
var knockback_timer := 0.0


func _ready() -> void:
	recalculate_stats()
	current_health = max_health
	health_label.text = str(current_health)

func _process(_delta: float) -> void:
	aim_pivot.look_at(get_global_mouse_position())


func _physics_process(delta: float) -> void:
	if(dash_cooldown_timer > 0):
		dash_cooldown_timer -= delta
	else:
		can_dash = true
		dash_label.text = "Can Dash"

	match current_state:
		
		State.MOVE:
			move_state(delta)
		
		State.DASH:
			dash_state(delta)
		
		State.KNOCKBACK:
			knockback_state(delta)
		
		State.DEAD:
			dead_state(delta)

func change_state(new_state):
	current_state = new_state
	
	if current_state == State.DASH:
		dash_timer = dash_time
		dash_direction = Input.get_vector("left","right","up","down")
	
	if current_state == State.DEAD:
		print("You died")

func move_state(delta):

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector("left", "right","up","down")
	
	#Check if dash was pressed
	if(Input.is_action_just_pressed("dash")):
		if(can_dash == true):
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
	can_dash = false
	dash_label.text = "Cannot Dash"

	velocity = dash_direction * dash_speed

	move_and_slide()

	dash_timer -= delta

	if(dash_timer <0):
		dash_cooldown_timer = dash_cooldown_time
		change_state(State.MOVE)

func knockback_state(delta):
	set_collision_layer_value(1, false)
	velocity = knockback_direction * knockback_speed
	move_and_slide()

	knockback_timer -= delta

	if knockback_timer <= 0:
		set_collision_layer_value(1, true)
		change_state(State.MOVE)

func dead_state(_delta):
	pass

func shoot():
	if(not shoot_timer.is_stopped()):
		return
	
	var bullet = BULLET_SCENE.instantiate()
	bullet.damage = damage
	
	get_tree().current_scene.add_child(bullet)
	
	bullet.global_position = $AimPivot/BulletSpawn.global_position
	bullet.direction = global_position.direction_to(get_global_mouse_position())
	bullet.rotation = bullet.direction.angle() + deg_to_rad(90)
	
	shoot_timer.start(1.0 / fire_rate)

func get_hit(amount : int, source_position : Vector2):
	current_health -= amount
	health_label.text = str(current_health)
	
	if current_health <= 0:
		change_state(State.DEAD)
	else:
		knockback_direction = source_position.direction_to(global_position)
		knockback_timer = knockback_time
		change_state(State.KNOCKBACK)

func recalculate_stats() -> void:
	var damage_percent := 0.0
	var movement_speed_percent := 0.0
	var fire_rate_percent := 0.0
	var max_health_percent := 0.0

	for effect in consumed_effects:
		damage_percent += effect.damage_percent
		movement_speed_percent += effect.movement_speed_percent
		fire_rate_percent += effect.fire_rate_percent
		max_health_percent += effect.max_health_percent

	damage = base_damage * (1.0 + damage_percent)
	movement_speed = base_movement_speed * (1.0 + movement_speed_percent)
	fire_rate = base_fire_rate * (1.0 + fire_rate_percent)
	max_health = base_max_health * (1.0 + max_health_percent)
	

	print("Damage: ", damage)
	print("Movement Speed: ", movement_speed)
	print("Fire Rate: ", fire_rate)
	print("Max Health: ", max_health)

func apply_slime_effect(effect: SlimeEffect) -> void:
	var old_max_health = max_health
	
	consumed_effects.append(effect)
	recalculate_stats()
	
	var health_change = max_health - old_max_health
	current_health += health_change
	
	current_health = max(current_health, 1.0)
	health_label.text = str(current_health)
