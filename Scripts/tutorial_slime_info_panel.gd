extends PanelContainer

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel

func show_slime_info(effect: SlimeEffect) -> void:
	name_label.text = "Tutorial Slime"
	description_label.text = "+200% Game Enjoyment, -6% Game Frustration. Consume (E)"
	show()

func hide_slime_info() -> void:
	hide()
