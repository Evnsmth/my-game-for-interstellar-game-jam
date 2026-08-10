extends CharacterBody2D

@onready var player: CharacterBody2D
@onready var enemy_start: Marker2D = $"../EnemyStart"

@export var speed = 30.0
@export var max_health = 25.0
@export var contact_damage = 0.0
@export var dropped_slime_effect: SlimeEffect
@onready var tutorial: Node2D = get_tree().get_first_node_in_group("tutorial")

const SLIME_PUDDLE_SCENE = preload("res://Scenes/tutorial_slime_puddle.tscn")

var current_health = max_health
var can_move : bool = false

func _ready() -> void:
	player  = get_tree().get_first_node_in_group("player")
	tutorial.start_enemy.connect(_on_start_enemy)

func _physics_process(_delta: float) -> void:
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


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("get_hit"):
		body.get_hit(contact_damage, global_position)
