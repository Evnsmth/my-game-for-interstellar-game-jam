extends Node2D

@export var final_choice: CanvasLayer

var player_nearby := false


func _ready() -> void:
	print("FINAL PUDDLE SCRIPT LOADED")

func _process(_delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed("consume"):
		print("CONSUME PRESSED")
		print("Final choice is: ", final_choice)
		final_choice.open()


func _on_body_entered(body: Node2D) -> void:
	print("BODY ENTERED: ", body.name)
	if body.is_in_group("player"):
		player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
