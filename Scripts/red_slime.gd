extends CharacterBody2D

signal died

@onready var player: CharacterBody2D
@onready var telegraph_timer: Timer = $TelegraphTimer
@onready var dash_timer: Timer = $DashTimer
@onready var recovery_timer: Timer = $RecoveryTimer
@onready var sprite: Sprite2D = $Sprite2D

@export var max_health = 30.0
@export var contact_damage = 15.0
@export var chase_speed := 70.0
@export var dash_speed := 300.0
@export var dash_range := 100.0
@export var telegraph_time := 0.5
@export var dash_duration := 0.3
@export var recovery_time := 0.6
@export var dropped_slime_effect: SlimeEffect

@export var idle_squish_amount := 0.05
@export var idle_squish_speed := 5.0

@export var move_squish_amount := 0.10
@export var move_squish_speed := 10.0

const SLIME_PUDDLE_SCENE = preload("res://Scenes/slime_puddle.tscn")

enum State {
	CHASE,
	TELEGRAPH,
	DASH,
	RECOVER
}

var state = State.CHASE
var current_health = max_health
var squish_time := 0.0
var death_scale := Vector2.ONE
var dash_direction : Vector2

func _ready() -> void:
	sprite.material = sprite.material.duplicate()
	player  = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	match state:
		State.CHASE:
			update_squish(delta)
			var direction = global_position.direction_to(player.global_position)
			velocity = direction * chase_speed
			move_and_slide()
			
			if(global_position.distance_to(player.global_position) <= dash_range):
				telegraph_timer.start(telegraph_time)
				state = State.TELEGRAPH
		
		State.TELEGRAPH:
			update_squish(delta)
			velocity = Vector2.ZERO
			if(telegraph_timer.time_left <= 0):
				dash_direction = global_position.direction_to(player.global_position)
				dash_timer.start(dash_duration)
				state = State.DASH
		
		State.DASH:
			update_squish(delta)
			velocity = dash_direction * dash_speed
			move_and_slide()
			
			if(dash_timer.time_left <= 0):
				recovery_timer.start(recovery_time)
				state = State.RECOVER
		
		State.RECOVER:
			update_squish(delta)
			velocity = Vector2.ZERO
			if(recovery_timer.time_left <= 0):
				state = State.CHASE

func take_damage(amount : int):
	current_health -= amount
	play_hit_flash()
	
	if current_health <= 0:
		die()

func die():
	var puddle: SlimePuddle = SLIME_PUDDLE_SCENE.instantiate()

	puddle.global_position = global_position
	puddle.slime_effect = dropped_slime_effect

	get_tree().current_scene.add_child(puddle)

	died.emit()
	await play_death_squash()
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

	var base_scale = Vector2(
		1.0 + squish,
		1.0 - squish
	)
	sprite.scale = base_scale * death_scale

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
		recovery_timer.start(recovery_time)
		state = State.RECOVER
