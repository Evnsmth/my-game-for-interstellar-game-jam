extends CharacterBody2D

signal died

const BULLET_SCENE = preload("res://Scenes/Enemies/enemy_purple_bullet.tscn")

@onready var player: CharacterBody2D
@onready var top_left = get_tree().get_first_node_in_group("teleport_top_left")
@onready var bottom_right = get_tree().get_first_node_in_group("teleport_bottom_right")
@onready var telegraph_timer: Timer = $TelegraphTimer
@onready var recovery_timer: Timer = $RecoveryTimer
@onready var sprite: Sprite2D = $Sprite2D

@export var speed = 100.0
@export var max_health = 33.0
@export var contact_damage = 10.0
@export var bullet_damage = 13.0
@export var wall_clearance: float = 25.0
@export var teleport_attempts: int = 20
@export var minimum_player_distance: float = 60.0
@export var telegraph_time: float = 0.3
@export var recovery_time: float = 2.5
@export var dropped_slime_effect: SlimeEffect

@export var idle_squish_amount := 0.05
@export var idle_squish_speed := 5.0

@export var move_squish_amount := 0.10
@export var move_squish_speed := 10.0

const SLIME_PUDDLE_SCENE = preload("res://Scenes/slime_puddle.tscn")

enum State {
	TELEPORT,
	TELEGRAPH,
	SHOOT,
	RECOVER
}

var state = State.RECOVER

var current_health = max_health
var squish_time := 0.0

func _ready() -> void:
	recovery_timer.start(1.25)
	player  = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	match state:
		State.TELEPORT:
			update_squish(delta)
			global_position = choose_teleport_position()
			telegraph_timer.start(telegraph_time)
			state = State.TELEGRAPH
		
		State.TELEGRAPH:
			update_squish(delta)
			velocity = Vector2.ZERO
			if(telegraph_timer.time_left <= 0):
				state = State.SHOOT
		
		State.SHOOT:
			update_squish(delta)
			shoot_cardinals()
			shoot_diagonals()
			recovery_timer.start(recovery_time)
			state = State.RECOVER
		
		State.RECOVER:
			update_squish(delta)
			velocity = Vector2.ZERO
			if(recovery_timer.time_left <= 0):
				state = State.TELEPORT

func choose_teleport_position() -> Vector2:
	for attempt in teleport_attempts:
		var random_angle = randf_range(0.0, TAU)
		var random_distance = randf_range(88.0,150)
		
		var candidate =  player.global_position + Vector2.from_angle(random_angle) * random_distance
		
		if not is_inside_floor(candidate):
			continue
		
		if candidate.distance_to(player.global_position) < minimum_player_distance:
			continue
		
		if(is_teleport_position_clear(candidate)):
			return candidate
	
	return global_position

func is_teleport_position_clear(target_position: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state

	var circle = CircleShape2D.new()
	circle.radius = wall_clearance

	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0.0, target_position)
	query.collision_mask = 4

	var collisions = space_state.intersect_shape(query)

	return collisions.is_empty()

func is_inside_floor(candidate: Vector2) -> bool:
	return (
		candidate.x >= top_left.global_position.x
		and candidate.x <= bottom_right.global_position.x
		and candidate.y >= top_left.global_position.y
		and candidate.y <= bottom_right.global_position.y
	)

func shoot_cardinals():
	var cardinal_directions = [
		Vector2.UP,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.RIGHT
	]

	for direction in cardinal_directions:
		var bullet = BULLET_SCENE.instantiate()
		bullet.damage = bullet_damage
		bullet.direction = direction

		get_tree().current_scene.add_child(bullet)

		bullet.global_position = global_position
		bullet.rotation = direction.angle() + deg_to_rad(90)

func shoot_diagonals():
	var diagonal_directions = [
		Vector2(-1, -1),
		Vector2(1, -1),
		Vector2(-1, 1),
		Vector2(1, 1)
	]

	for direction in diagonal_directions:
		direction = direction.normalized()

		var bullet = BULLET_SCENE.instantiate()
		bullet.damage = bullet_damage
		bullet.direction = direction

		get_tree().current_scene.add_child(bullet)

		bullet.global_position = global_position
		bullet.rotation = direction.angle() + deg_to_rad(90)

func take_damage(amount : int):
	current_health -= amount
	
	if current_health <= 0:
		die()

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

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("get_hit"):
		body.get_hit(contact_damage, global_position)
