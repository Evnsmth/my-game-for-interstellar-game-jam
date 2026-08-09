extends CanvasLayer


@onready var progress_bar: TextureProgressBar = $MarginContainer/VBoxContainer/TextureProgressBar
@onready var percent_label: Label = $MarginContainer/VBoxContainer/PercentLabel

func _process(_delta):
	progress_bar.value = RunManager.assimilation
	percent_label.text = str(roundi(RunManager.assimilation)) + "%"
