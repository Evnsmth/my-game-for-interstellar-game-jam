extends CharacterBody2D

signal died

const SHOCKWAVE_SCENE = preload("res://Scenes/Enemies/shock_wave_ring.tscn")

@onready var player: CharacterBody2D
@onready var explosion_timer: Timer = $ExplosionTimer
@onready var sprite: Sprite2D = $Regular


@export var speed = 55.0
@export var max_health = 75.0
@export var contact_damage = 10.0
@export var explosion_time = 4.0
@export var explosion_damage = 30.0
@export var dropped_slime_effect: SlimeEffect

@export var idle_squish_amount := 0.035
@export var idle_squish_speed := 3.5

@export var move_squish_amount := 0.07
@export var move_squish_speed := 7.0

const SLIME_PUDDLE_SCENE = preload("res://Scenes/slime_puddle.tscn")

enum State {
	CHASE,
	EXPLODE
}

var state = State.CHASE

var current_health = max_health
var squish_time := 0.0
var normal_color : Color

func _ready() -> void:
	player  = get_tree().get_first_node_in_group("player")
	sprite.material = sprite.material.duplicate()
	normal_color = sprite.modulate

func _physics_process(delta: float) -> void:
	match state:
		State.CHASE:
			update_squish(delta)
			var direction = global_position.direction_to(player.global_position)
			velocity = direction * speed
			move_and_slide()
		
		State.EXPLODE:
			# Flash 1
			#play_hit_flash()
			await get_tree().create_timer(0.25).timeout
			sprite.modulate = normal_color

			await get_tree().create_timer(0.12).timeout

			# Flash 2
			#play_hit_flash()
			await get_tree().create_timer(0.25).timeout
			sprite.modulate = normal_color

			await get_tree().create_timer(0.10).timeout

			# Flash 3
			#play_hit_flash()
			await get_tree().create_timer(0.25).timeout
			sprite.modulate = normal_color

			spawn_shockwave()
			die()

func spawn_shockwave() -> void:
	var camera = get_tree().get_first_node_in_group("camera")

	camera.shake(3.0)
	var ring = SHOCKWAVE_SCENE.instantiate()
	ring.max_radius = ring.max_radius - 70

	get_tree().current_scene.add_child(ring)

	ring.global_position = global_position
	ring.damage = explosion_damage
	pass

func take_damage(amount : int):
	current_health -= amount
	#play_hit_flash()
	
	if current_health <= 0:
		explosion_timer.start(explosion_time)
		state = State.EXPLODE

func die():
	var puddle: SlimePuddle = SLIME_PUDDLE_SCENE.instantiate()

	puddle.global_position = global_position
	puddle.slime_effect = dropped_slime_effect

	get_tree().current_scene.add_child(puddle)

	died.emit()
	queue_free()

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
