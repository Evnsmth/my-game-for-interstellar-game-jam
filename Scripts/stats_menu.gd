extends PanelContainer

@onready var player = get_tree().get_first_node_in_group("player")
@onready var health_label: Label = $VBoxContainer/HealthLabel
@onready var damage_label: Label = $VBoxContainer/DamageLabel
@onready var fire_rate_label: Label = $VBoxContainer/FireRateLabel
@onready var movement_label: Label = $VBoxContainer/MovementLabel

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("stats_menu_open"):
		if visible:
			close_menu()
		else:
			open_menu()

func open_menu():
	get_tree().paused = true
	health_label.text = str(snapped((((player.max_health / player.base_max_health) - 1)*100), 0.01)) + "%"
	damage_label.text = str(snapped((((player.damage / player.base_damage) - 1)*100), 0.01)) + "%"
	fire_rate_label.text = str(snapped((((player.fire_rate / player.base_fire_rate) - 1)*100), 0.01)) + "%"
	movement_label.text = str(snapped((((player.movement_speed / player.base_movement_speed) - 1)*100), 0.01)) + "%"
	show()

func close_menu():
	get_tree().paused = false
	hide()
