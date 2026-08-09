extends CharacterBody2D

signal died

const SHOCKWAVE_SCENE = preload("res://Scenes/Enemies/shock_wave_ring.tscn")

@onready var player: CharacterBody2D
@onready var explosion_timer: Timer = $ExplosionTimer
@onready var sprite: Sprite2D = $Regular


@export var speed = 30.0
@export var max_health = 75.0
@export var contact_damage = 10.0
@export var explosion_time = 4.0
@export var explosion_damage = 30.0
@export var dropped_slime_effect: SlimeEffect

const SLIME_PUDDLE_SCENE = preload("res://Scenes/slime_puddle.tscn")

enum State {
	CHASE,
	EXPLODE
}

var state = State.CHASE

var current_health = max_health
var normal_color : Color

func _ready() -> void:
	player  = get_tree().get_first_node_in_group("player")
	normal_color = sprite.modulate

func _physics_process(_delta: float) -> void:
	match state:
		State.CHASE:
			var direction = global_position.direction_to(player.global_position)
			velocity = direction * speed
			move_and_slide()
		
		State.EXPLODE:
			# Flash 1
			sprite.modulate = Color(2.5, 2.5, 2.5)
			await get_tree().create_timer(0.25).timeout
			sprite.modulate = normal_color

			await get_tree().create_timer(0.12).timeout

			# Flash 2
			sprite.modulate = Color(2.5, 2.5, 2.5)
			await get_tree().create_timer(0.25).timeout
			sprite.modulate = normal_color

			await get_tree().create_timer(0.10).timeout

			# Flash 3
			sprite.modulate = Color(2.5, 2.5, 2.5)
			await get_tree().create_timer(0.25).timeout
			sprite.modulate = normal_color

			spawn_shockwave()
			die()

func spawn_shockwave() -> void:
	var ring = SHOCKWAVE_SCENE.instantiate()

	get_tree().current_scene.add_child(ring)

	ring.global_position = global_position
	ring.damage = explosion_damage
	pass

func take_damage(amount : int):
	current_health -= amount
	
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


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("get_hit"):
		body.get_hit(contact_damage, global_position)
