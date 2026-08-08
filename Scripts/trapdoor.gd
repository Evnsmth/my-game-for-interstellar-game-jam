extends Area2D

@onready var close_sprite = $Closed
@onready var open_sprite = $Open

signal trapdoor_entered

var player_ready: bool = false

func close() -> void:
	close_sprite.show()
	open_sprite.hide()

func open():
	close_sprite.hide()
	open_sprite.show()

func _on_body_entered(body: Node2D) -> void:
	if(open_sprite.visible == true):
		if(body.is_in_group("player")):
			player_ready = true

func _on_body_exited(body: Node2D) -> void:
	if(open_sprite.visible == true):
		if(body.is_in_group("player")):
			player_ready = false

func _unhandled_input(event: InputEvent) -> void:
	if player_ready and event.is_action_pressed("interact"):
		trapdoor_entered.emit()
