extends CanvasLayer


func _ready() -> void:
	hide()


func show_death_screen() -> void:
	show()
	get_tree().paused = true


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	RunManager.start_new_run()
	get_tree().reload_current_scene()


func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	RunManager.start_new_run()
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
