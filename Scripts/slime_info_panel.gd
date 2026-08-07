extends PanelContainer

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel

func show_slime_info(effect: SlimeEffect) -> void:
	name_label.text = effect.effect_name
	description_label.text = effect.description
	show()

func hide_slime_info() -> void:
	hide()
