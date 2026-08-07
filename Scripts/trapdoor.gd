extends Area2D

@onready var close_sprite = $Closed
@onready var open_sprite = $Open


func free() -> void:
	close_sprite.show()
	open_sprite.hide()

func open():
	close_sprite.hide()
	open_sprite.show()
