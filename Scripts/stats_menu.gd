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
	health_label.text = "Health: " + str(player.current_health) + " / " + str(player.max_health) + " Stat Change Percent: " + str(snapped(((player.max_health / player.base_max_health) - 1), 0.01))
	damage_label.text = "Damage: " + str(player.damage) + " Stat Change Percent: " + str(snapped(((player.damage / player.base_damage) - 1), 0.01))
	fire_rate_label.text = "Fire Rate: " + str(player.fire_rate) + " Stat Change Percent: " + str(snapped(((player.fire_rate / player.base_fire_rate) - 1), 0.01))
	movement_label.text = "Movement Speed: " + str(player.movement_speed) + " Stat Change Percent: " + str(snapped(((player.movement_speed / player.base_movement_speed) - 1), 0.01))
	show()

func close_menu():
	get_tree().paused = false
	hide()
