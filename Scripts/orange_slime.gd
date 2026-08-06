extends CharacterBody2D

@onready var player: CharacterBody2D

@export var speed = 100.0

func _ready() -> void:
	player  = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)

	velocity = direction * speed

	move_and_slide()
