extends Node2D

@export var final_choice: CanvasLayer
@onready var sprite: Sprite2D = $Sprite2D

var player_nearby := false


func _ready() -> void:
	print("FINAL PUDDLE SCRIPT LOADED")

func _process(_delta: float) -> void:
	start_wobble()
	if player_nearby and Input.is_action_just_pressed("consume"):
		print("CONSUME PRESSED")
		print("Final choice is: ", final_choice)
		final_choice.open()

func start_wobble():
	var tween = create_tween()
	tween.set_loops()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		sprite,
		"scale",
		Vector2(1.04, 0.96),
		0.6
	)

func _on_body_entered(body: Node2D) -> void:
	print("BODY ENTERED: ", body.name)
	if body.is_in_group("player"):
		player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
