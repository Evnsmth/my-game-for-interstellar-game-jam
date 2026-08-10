extends CharacterBody2D

signal died

const BULLET_SCENE = preload("res://Scenes/Enemies/enemy_blue_bullet.tscn")

@onready var player: CharacterBody2D
@onready var telegraph_timer: Timer = $TelegraphTimer
@onready var shoot_timer: Timer = $ShootTimer
@onready var recovery_timer: Timer = $RecoveryTimer
@onready var reposition_timer: Timer = $RepositionTimer
@onready var sprite: Sprite2D = $Sprite2D

@export var speed = 60.0
@export var max_health = 27.0
@export var contact_damage = 10.0
@export var bullet_damage = 12.0
@export var fire_rate = 2.0
@export var bullet_amount = 3
@export var shooting_distance = 150.0
@export var repostion_time = 3.0
@export var telegraph_time = 0.4
@export var recovery_time = 2.0
@export var dropped_slime_effect: SlimeEffect

@export var idle_squish_amount := 0.05
@export var idle_squish_speed := 5.0

@export var move_squish_amount := 0.10
@export var move_squish_speed := 10.0

const SLIME_PUDDLE_SCENE = preload("res://Scenes/slime_puddle.tscn")

enum State {
	REPOSITION,
	TELEGRAPH,
	SHOOT,
	RECOVER
}

var state = State.REPOSITION

var current_health = max_health
var squish_time := 0.0
var bullets_shot = 0
var strafe_sign = 1
var wall_sliding = false
var wall_slide_direction = Vector2.ZERO
var escaping_corner = false
var corner_escape_direction = Vector2.ZERO

func _ready() -> void:
	player  = get_tree().get_first_node_in_group("player")
	reposition_timer.start(repostion_time)
	strafe_sign = [-1, 1].pick_random()

func _physics_process(delta: float) -> void:
	match state:
		State.REPOSITION:
			update_squish(delta)
			var distance = global_position.distance_to(player.global_position)
			if distance < shooting_distance:
				if reposition_timer.time_left > 0:
					if wall_sliding:
						velocity = wall_slide_direction * speed
						move_and_slide()
					else:
						var away_direction = player.global_position.direction_to(global_position)
						velocity = away_direction * speed
						move_and_slide()
						if get_slide_collision_count() > 0:
							var collision = get_slide_collision(0)
							var wall_normal = collision.get_normal()
							wall_slide_direction = Vector2(
								-wall_normal.y,
								wall_normal.x
							)
							wall_slide_direction *= strafe_sign
							wall_sliding = true
				else:
					wall_sliding = false
					velocity = Vector2.ZERO
					telegraph_timer.start(telegraph_time)
					state = State.TELEGRAPH
			else:
				wall_sliding = false
				velocity = Vector2.ZERO
				telegraph_timer.start(telegraph_time)
				state = State.TELEGRAPH

		
		State.TELEGRAPH:
			update_squish(delta)
			velocity = Vector2.ZERO
			if(telegraph_timer.time_left <= 0):
				state = State.SHOOT
		
		State.SHOOT:
			update_squish(delta)
			velocity = Vector2.ZERO
			shoot()
		
		State.RECOVER:
			update_squish(delta)
			velocity = Vector2.ZERO
			if(recovery_timer.time_left <= 0):
				reposition_timer.start(repostion_time)
				state = State.REPOSITION

func shoot():
	if(bullets_shot >= bullet_amount):
		bullets_shot = 0
		recovery_timer.start(recovery_time)
		state = State.RECOVER
		return
	if(not shoot_timer.is_stopped()):
		return
	
	var bullet = BULLET_SCENE.instantiate()
	bullet.damage = bullet_damage
	
	get_tree().current_scene.add_child(bullet)
	
	bullet.global_position = global_position
	bullet.direction = global_position.direction_to(player.global_position)
	bullet.rotation = bullet.direction.angle() + deg_to_rad(90)
	bullets_shot += 1
	
	shoot_timer.start(1.0 / fire_rate)

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
