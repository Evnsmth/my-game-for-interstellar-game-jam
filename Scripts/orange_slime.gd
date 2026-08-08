extends CharacterBody2D

signal died

@onready var player: CharacterBody2D

@export var speed = 70.0
@export var max_health = 25.0
@export var contact_damage = 10.0
@export var dropped_slime_effect: SlimeEffect

const SLIME_PUDDLE_SCENE = preload("res://Scenes/slime_puddle.tscn")

var current_health = max_health

func _ready() -> void:
	player  = get_tree().get_first_node_in_group("player")
	if(dropped_slime_effect.effect_name == "Amber Slime"):
		dropped_slime_effect = create_random_amber_effect()

func _physics_process(_delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()

func create_random_amber_effect() -> SlimeEffect:
	var random_effect: SlimeEffect = dropped_slime_effect.duplicate()

	var stats = [
		"damage",
		"movement_speed",
		"fire_rate",
		"max_health"
	]

	var buff_stat = stats.pick_random()

	var possible_debuffs = stats.duplicate()
	possible_debuffs.erase(buff_stat)

	var debuff_stat = possible_debuffs.pick_random()

	match buff_stat:
		"damage":
			random_effect.damage_percent = 0.18
		"movement_speed":
			random_effect.movement_speed_percent = 0.18
		"fire_rate":
			random_effect.fire_rate_percent = 0.18
		"max_health":
			random_effect.max_health_percent = 0.18

	match debuff_stat:
		"damage":
			random_effect.damage_percent = -0.08
		"movement_speed":
			random_effect.movement_speed_percent = -0.08
		"fire_rate":
			random_effect.fire_rate_percent = -0.08
		"max_health":
			random_effect.max_health_percent = -0.08

	return random_effect

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
		body.get_hit(contact_damage, global_position)
