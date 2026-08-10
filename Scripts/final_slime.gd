extends CharacterBody2D

signal died

const SHOCKWAVE_SCENE = preload("res://Scenes/Enemies/shock_wave_ring.tscn")
const PBULLET_SCENE = preload("res://Scenes/Enemies/enemy_purple_bullet.tscn")
const BBULLET_SCENE = preload("res://Scenes/Enemies/enemy_blue_bullet.tscn")
@onready var label: Label = $Label
@onready var final_choice = get_tree().get_first_node_in_group("final")

@onready var player: CharacterBody2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var core_sprite: Sprite2D = $CoreSprite
@onready var core_light: PointLight2D = $CoreLight
@onready var explosion_cooldown_timer: Timer = $ExplosionCooldownTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var p_shoot_cooldown_timer: Timer = $PShootCooldownTimer
@onready var b_shoot_cooldown_timer: Timer = $BShootCooldownTimer
@onready var dash_timer: Timer = $DashTimer
@onready var b_shoot_timer: Timer = $BShootTimer
@onready var recovery_timer: Timer = $RecoveryTimer
@onready var telegraph_timer: Timer = $TelegraphTimer

@export_category("Basic Stats")
@export var speed = 100.0
@export var max_health = 10.0
@export var contact_damage = 25.0

@export_category("Explosion Attack")
@export var explosion_attack_range = 140.0
@export var explosion_cooldown_time = 8.0
@export var explosion_damage : float = 40.0
@export var explosion_recovery_time = 1.0

@export_category("Dash Attack") 
@export var dash_attack_range = 150.0
@export var dash_cooldown_time = 4.0
@export var dash_speed := 350.0
@export var dash_duration := 0.50
@export var dash_telegraph_time := 0.5
@export var dash_recovery_time := 0.3

@export_category("PShoot Attack")
@export var pshoot_attack_range = 175.0
@export var pshoot_cooldown_time = 6.0
@export var pshoot_damage = 15.0
@export var pshoot_fire_rate = 2.5
@export var pshoot_telegraph_time := 0.5
@export var pshoot_recovery_time := 0.5

@export_category("BShoot Attack")
@export var bshoot_attack_range = 225.0
@export var bshoot_cooldown_time = 7.0
@export var bshoot_bullet_amount = 5
@export var bshoot_damage = 20.0
@export var bshoot_fire_rate = 2.75
@export var bshoot_telegraph_time := 0.7
@export var bshoot_recovery_time := 0.6

@export var idle_squish_amount := 0.035
@export var idle_squish_speed := 3.5

@export var move_squish_amount := 0.05
@export var move_squish_speed := 5.0

const SLIME_PUDDLE_SCENE = preload("res://Scenes/final_puddle.tscn")

const COLOR_CRIMSON = Color("#ff3b4f")
const COLOR_AZURE = Color("#4db8ff")
const COLOR_VIOLET = Color("#b45cff")
const COLOR_IVORY = Color("#ffffff")
const COLOR_AMBER = Color("#ffad32")

var next_state = null
var squish_time := 0.0
var death_scale := Vector2.ONE
var normal_color : Color
var explosion_started: bool = false
var dash_direction = null
var bullets_shot = 0

enum State {
	CHASE,
	TELEGRAPH,
	EXPLODE,
	DASH,
	PSHOOT,
	BSHOOT,
	RECOVER
}

var state = State.CHASE

var current_health = max_health

func _ready() -> void:
	player  = get_tree().get_first_node_in_group("player")
	normal_color = sprite.modulate
	set_core_color(COLOR_AMBER)
	sprite.material = sprite.material.duplicate()
	p_shoot_cooldown_timer.start(pshoot_cooldown_time)
	b_shoot_cooldown_timer.start(bshoot_cooldown_time)


func _physics_process(delta: float) -> void:
	match state:
		State.CHASE:
			set_core_color(COLOR_AMBER)
			update_squish(delta)
			var direction = global_position.direction_to(player.global_position)
			velocity = direction * speed
			move_and_slide()
			
			check_possible_attacks()
			
		State.TELEGRAPH:
			update_squish(delta)
			velocity = Vector2.ZERO
			if(telegraph_timer.time_left <= 0):
				if(next_state == State.DASH):
					dash_timer.start(dash_duration)
					dash_direction = global_position.direction_to(player.global_position)
				state = next_state
		
		State.EXPLODE:
			update_squish(delta)
			velocity = Vector2.ZERO
			if not explosion_started:
				explosion_started = true
				do_explosion_attack()
		
		State.DASH:
			update_squish(delta)
			velocity = dash_direction * dash_speed
			move_and_slide()
			
			if(dash_timer.time_left <= 0):
				recovery_timer.start(dash_recovery_time)
				next_state = null
				dash_cooldown_timer.start(dash_cooldown_time)
				state = State.RECOVER
		
		State.PSHOOT:
			update_squish(delta)
			velocity = Vector2.ZERO
			do_pshoot_attack()
			
			recovery_timer.start(pshoot_recovery_time)
			next_state = null
			p_shoot_cooldown_timer.start(pshoot_cooldown_time)
			state = State.RECOVER
		
		State.BSHOOT:
			update_squish(delta)
			velocity = Vector2.ZERO
			do_bshoot_attack()
		
		State.RECOVER:
			update_squish(delta)
			if(recovery_timer.time_left <= 0):
				state = State.CHASE

func check_possible_attacks():
	if(global_position.distance_to(player.global_position) <= explosion_attack_range and explosion_cooldown_timer.time_left <= 0):
		set_core_color(COLOR_IVORY)
		state = State.EXPLODE
	elif(global_position.distance_to(player.global_position) <= dash_attack_range and dash_cooldown_timer.time_left <= 0):
		set_core_color(COLOR_CRIMSON)
		next_state = State.DASH
		telegraph_timer.start(dash_telegraph_time)
		state = State.TELEGRAPH
	elif(global_position.distance_to(player.global_position) <= pshoot_attack_range and p_shoot_cooldown_timer.time_left <= 0):
		set_core_color(COLOR_VIOLET)
		next_state = State.PSHOOT
		telegraph_timer.start(pshoot_telegraph_time)
		state = State.TELEGRAPH
	elif(global_position.distance_to(player.global_position) <= bshoot_attack_range and b_shoot_cooldown_timer.time_left <= 0):
		set_core_color(COLOR_AZURE)
		next_state = State.BSHOOT
		telegraph_timer.start(bshoot_telegraph_time)
		state = State.TELEGRAPH

func do_explosion_attack():
	# Flash 1
	play_hit_flash()
	await get_tree().create_timer(0.15).timeout
	sprite.modulate = normal_color

	await get_tree().create_timer(0.12).timeout

	# Flash 2
	play_hit_flash()
	await get_tree().create_timer(0.15).timeout
	sprite.modulate = normal_color

	await get_tree().create_timer(0.10).timeout

	# Flash 3
	play_hit_flash()
	await get_tree().create_timer(0.15).timeout
	sprite.modulate = normal_color

	spawn_shockwave()

	explosion_started = false

	recovery_timer.start(explosion_recovery_time)
	explosion_cooldown_timer.start(explosion_cooldown_time)
	state = State.RECOVER

func spawn_shockwave() -> void:
	var camera = get_tree().get_first_node_in_group("camera")

	camera.shake(3.0)
	var ring = SHOCKWAVE_SCENE.instantiate()
	ring.max_radius = ring.max_radius + 25
	ring.expand_speed = ring.expand_speed + 50

	get_tree().current_scene.add_child(ring)

	ring.global_position = global_position
	ring.global_position.y = global_position.y + 10
	ring.damage = explosion_damage

func do_pshoot_attack():
	var first_wave_directions = [
				Vector2.UP,
				Vector2.DOWN,
				Vector2.LEFT,
				Vector2.RIGHT,
				Vector2(-1, -1),
				Vector2(1, -1),
				Vector2(-1, 1),
				Vector2(1, 1)
			]

	for direction in first_wave_directions:
		var bullet = PBULLET_SCENE.instantiate()
		bullet.speed = bullet.speed + 50
		bullet.damage = pshoot_damage
		bullet.direction = direction

		get_tree().current_scene.add_child(bullet)

		bullet.global_position = global_position
		bullet.global_position.y = global_position.y + 10
		bullet.rotation = direction.angle() + deg_to_rad(90)
			
	await get_tree().create_timer(1 / pshoot_fire_rate).timeout
			
	var second_wave_directions = []
			
	for i in range(8):
		var angle = deg_to_rad(22.5 + i * 45.0)
		var direction = Vector2.RIGHT.rotated(angle)
		second_wave_directions.append(direction)

	for direction in second_wave_directions:
		var bullet = PBULLET_SCENE.instantiate()
		bullet.speed = bullet.speed + 50
		bullet.damage = pshoot_damage
		bullet.direction = direction

		get_tree().current_scene.add_child(bullet)

		bullet.global_position = global_position
		bullet.global_position.y = global_position.y + 10
		bullet.rotation = direction.angle() + deg_to_rad(90)

func do_bshoot_attack():
	if(bullets_shot >= bshoot_bullet_amount):
		bullets_shot = 0
		recovery_timer.start(bshoot_recovery_time)
		next_state = null
		b_shoot_cooldown_timer.start(bshoot_cooldown_time)
		state = State.RECOVER
		return
	if(not b_shoot_timer.is_stopped()):
		return
	
	var bullet = BBULLET_SCENE.instantiate()
	bullet.speed = bullet.speed + 140
	bullet.damage = bshoot_damage
	
	get_tree().current_scene.add_child(bullet)
	
	bullet.global_position = global_position
	bullet.direction = global_position.direction_to(player.global_position)
	bullet.rotation = bullet.direction.angle() + deg_to_rad(90)
	bullets_shot += 1
	
	b_shoot_timer.start(1.0 / bshoot_fire_rate)

func take_damage(amount : int):
	current_health -= amount
	label.text = str(current_health)
	play_hit_flash()
	
	if current_health <= 0:
		die()

func die():
	var puddle = SLIME_PUDDLE_SCENE.instantiate()

	puddle.global_position = global_position

	get_tree().current_scene.add_child(puddle)
	

	died.emit()
	await play_death_squash()
	final_choice.open()
	queue_free()

func set_core_color(new_color: Color):
	core_sprite.modulate = new_color
	core_light.color = new_color

func play_hit_flash():
	var shader_material := sprite.material as ShaderMaterial

	if shader_material == null:
		return

	shader_material.set_shader_parameter("flash_amount", 1.0)

	var tween = create_tween()

	tween.tween_method(
		func(value):
			shader_material.set_shader_parameter("flash_amount", value),
		1.0,
		0.0,
		0.12
	)

func update_squish(delta):
	squish_time += delta

	var is_moving = velocity.length() > 5.0

	var amount = idle_squish_amount
	var speed = idle_squish_speed

	if is_moving:
		amount = move_squish_amount
		speed = move_squish_speed

	var squish = sin(squish_time * speed) * amount

	var base_scale = Vector2(
		1.0 + squish,
		1.0 - squish
	)
	sprite.scale = base_scale * death_scale

func play_death_squash():
	var tween = create_tween()

	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(
		self,
		"death_scale",
		Vector2(1.5, 0.15),
		0.18
	)

	tween.parallel().tween_property(
		sprite,
		"modulate:a",
		0.0,
		0.18
	)
	
	await tween.finished

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("get_hit"):
		body.get_hit(contact_damage, global_position)
