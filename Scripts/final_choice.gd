extends CanvasLayer

func _ready() -> void:
	hide()


func open() -> void:
	show()
	get_tree().paused = true


func _on_consume_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/consume_ending.tscn")


func _on_leave_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/leave_ending.tscn")
