extends CharacterBody2D

signal died

@onready var player: CharacterBody2D

@export var speed = 25.0
@export var max_health = 70.0
@export var dropped_slime_effect: SlimeEffect

const SLIME_PUDDLE_SCENE = preload("res://Scenes/slime_puddle.tscn")

var current_health = max_health

func _ready() -> void:
	player  = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)

	velocity = direction * speed

	move_and_slide()

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


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("get_hit"):
		body.get_hit(1, global_position)
