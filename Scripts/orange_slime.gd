extends CharacterBody2D

signal died

@onready var player: CharacterBody2D

@export var speed = 100.0
@export var max_health = 3

const SLIME_PUDDLE_SCENE = preload("res://Scenes/slime_puddle.tscn")

var current_health = max_health

func _ready() -> void:
	player  = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)

	velocity = direction * speed

	move_and_slide()

func take_damage(amount : int):
	current_health -= amount
	print("Enemy Health", current_health)
	
	if current_health <= 0:
		die()

func die():
	var slime_puddle = SLIME_PUDDLE_SCENE.instantiate()
	get_tree().current_scene.add_child(slime_puddle)
	slime_puddle.global_position = position
	died.emit()
	queue_free()


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("get_hit"):
		body.get_hit(1, position)
