extends Control

func _ready() -> void:
	RunManager.start_new_run()


func _on_play_button_pressed() -> void:
	RunManager.start_new_run()
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/tutorial.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
