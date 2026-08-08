extends CharacterBody2D

signal died

@onready var player: CharacterBody2D
@onready var telegraph_timer: Timer = $TelegraphTimer
@onready var dash_timer: Timer = $DashTimer
@onready var recovery_timer: Timer = $RecoveryTimer

@export var max_health = 25.0
@export var contact_damage = 20.0
@export var chase_speed := 70.0
@export var dash_speed := 350.0
@export var dash_range := 100.0
@export var telegraph_time := 0.4
@export var dash_duration := 0.3
@export var recovery_time := 0.6
@export var dropped_slime_effect: SlimeEffect

const SLIME_PUDDLE_SCENE = preload("res://Scenes/slime_puddle.tscn")

enum State {
	CHASE,
	TELEGRAPH,
	DASH,
	RECOVER
}

var state = State.CHASE
var current_health = max_health
var dash_direction : Vector2

func _ready() -> void:
	player  = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	match state:
		State.CHASE:
			var direction = global_position.direction_to(player.global_position)
			velocity = direction * chase_speed
			move_and_slide()
			
			if(global_position.distance_to(player.global_position) <= dash_range):
				telegraph_timer.start(telegraph_time)
				state = State.TELEGRAPH
		
		State.TELEGRAPH:
			velocity = Vector2.ZERO
			if(telegraph_timer.time_left <= 0):
				dash_direction = global_position.direction_to(player.global_position)
				dash_timer.start(dash_duration)
				state = State.DASH
		
		State.DASH:
			velocity = dash_direction * dash_speed
			move_and_slide()
			
			if(dash_timer.time_left <= 0):
				recovery_timer.start(recovery_time)
				state = State.RECOVER
		
		State.RECOVER:
			velocity = Vector2.ZERO
			if(recovery_timer.time_left <= 0):
				state = State.CHASE

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
		recovery_timer.start(recovery_time)
		state = State.RECOVER
