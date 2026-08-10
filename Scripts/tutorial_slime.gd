extends CharacterBody2D

@onready var player: CharacterBody2D
@onready var enemy_start: Marker2D = $"../EnemyStart"
@onready var tutorial: Node2D = get_tree().get_first_node_in_group("tutorial")
@onready var sprite: Sprite2D = $Sprite2D

@export var speed = 30.0
@export var max_health = 25.0
@export var contact_damage = 0.0
@export var dropped_slime_effect: SlimeEffect

@export var idle_squish_amount := 0.05
@export var idle_squish_speed := 5.0

@export var move_squish_amount := 0.10
@export var move_squish_speed := 10.0

const SLIME_PUDDLE_SCENE = preload("res://Scenes/tutorial_slime_puddle.tscn")

var current_health = max_health
var squish_time := 0.0
var can_move : bool = false

func _ready() -> void:
	player  = get_tree().get_first_node_in_group("player")
	tutorial.start_enemy.connect(_on_start_enemy)

func _physics_process(delta: float) -> void:
	update_squish(delta)
	if can_move:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()

func _on_start_enemy():
	global_position = enemy_start.global_position
	can_move = true

func take_damage(amount : int):
	current_health -= amount
	
	if current_health <= 0:
		die()

func die():
	var puddle = SLIME_PUDDLE_SCENE.instantiate()

	puddle.global_position = global_position
	puddle.slime_effect = dropped_slime_effect
	puddle.can_see_text = true

	get_tree().current_scene.add_child(puddle)
	tutorial.enemy_defeated = true
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
