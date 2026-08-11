extends CharacterBody2D

# Never give up on the things that bring you the most joy

# Special thanks to Henry, Leo, Charlotte, and Dad

signal died

enum State {
	MOVE,
	DASH,
	KNOCKBACK,
	CONSUME,
	DEAD
}

#region Constants
const BULLET_SCENE = preload("res://Scenes/bullet.tscn")
#endregion

#region Onready Variables
@onready var aim_pivot: Node2D = $AimPivot
@onready var shoot_timer: Timer = $ShootTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var puddle: Sprite2D = $Puddle
@onready var health_bar: TextureProgressBar = get_tree().get_first_node_in_group("health_bar")
@onready var health_label: Label = get_tree().get_first_node_in_group("health_label")
@onready var roll_ui: TextureProgressBar = get_tree().get_first_node_in_group("roll_ui")
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
@export var dash_time = 0.25
@export var dash_cooldown_time = 1.0
@export var dash_speed = 300.0
@export var knockback_speed := 300.0
@export var knockback_time := 0.125
@export var invincibility_time := 0.8

@export var idle_squish_amount := 0.075
@export var idle_squish_speed := 7.5

@export var move_squish_amount := 0.12
@export var move_squish_speed := 12.0

var current_state: State = State.MOVE
var can_control := true
var squish_time := 0.0
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var can_dash = true
var dash_direction = Vector2.ZERO
var knockback_direction := Vector2.ZERO
var knockback_timer := 0.0
var invincible := false
var invincibility_timer := 0.0


func _ready() -> void:
	recalculate_stats()
	if roll_ui != null:
		roll_ui.value = 1.0
	current_health = max_health
	if health_label != null:
		health_label.text = str(current_health)
	if health_bar != null:
		health_bar.max_value = max_health
		health_bar.value = current_health
	sprite.play("idle")

func _process(_delta: float) -> void:
	aim_pivot.look_at(get_global_mouse_position())


func _physics_process(delta: float) -> void:
	if(dash_cooldown_timer > 0):
		dash_cooldown_timer -= delta
		if roll_ui != null:
			roll_ui.value = 1.0 - (dash_cooldown_timer / dash_cooldown_time)
	else:
		can_dash = true
	if invincibility_timer > 0:
		invincibility_timer -= delta
	else:
		if invincible:
			invincible = false
			set_collision_layer_value(1, true)
	sprite.modulate.a = 0.5 if invincible else 1.0

	match current_state:
		
		State.MOVE:
			update_squish(delta)
			move_state(delta)
		
		State.DASH:
			dash_state(delta)
		
		State.KNOCKBACK:
			update_squish(delta)
			knockback_state(delta)
		
		State.CONSUME:
			velocity = Vector2.ZERO
			move_and_slide()
		
		State.DEAD:
			dead_state(delta)

func change_state(new_state):
	current_state = new_state
	
	match current_state:

		State.MOVE:
			sprite.play("idle")

		State.DASH:
			sprite.play("roll")
			dash_timer = dash_time
			dash_direction = Input.get_vector(
				"left",
				"right",
				"up",
				"down"
			)
			if roll_ui != null:
				roll_ui.value = 0.0

		State.CONSUME:
			sprite.play("consume")

		State.DEAD:
			sprite.hide()
			puddle.show()

func move_state(delta):
	if not can_control:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector("left", "right","up","down")
	
	#Check if dash was pressed
	if(Input.is_action_just_pressed("dash")):
		if(can_dash == true):
			change_state(State.DASH)
	
	if(Input.is_action_pressed("shoot")):
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

	velocity = dash_direction * (dash_speed * (movement_speed / base_movement_speed))

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

func consume_slime(effect: SlimeEffect) -> void:
	change_state(State.CONSUME)

	await sprite.animation_finished

	apply_slime_effect(effect)

	change_state(State.MOVE)

func dead_state(_delta):
	died.emit()

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

func update_squish(delta):
	squish_time += delta

	var is_moving = velocity.length() > 5.0

	var amount = idle_squish_amount
	var speed = idle_squish_speed

	if is_moving:
		amount = move_squish_amount
		speed = move_squish_speed

	var squish = sin(squish_time * speed) * amount

	sprite.scale = Vector2(
		1.0 + squish,
		1.0 - squish
	)

func get_hit(amount : int, source_position : Vector2):
	if invincible:
		return
	
	var camera = get_tree().get_first_node_in_group("camera")

	camera.shake(2.0)

	invincible = true
	invincibility_timer = invincibility_time

	current_health -= amount
	if health_bar != null:
		health_bar.value = current_health
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
	health_bar.max_value = max_health
