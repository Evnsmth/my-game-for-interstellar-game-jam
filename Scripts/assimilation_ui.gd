extends CanvasLayer


@onready var progress_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
@onready var percent_label: Label = $MarginContainer/VBoxContainer/PercentLabel

func _process(_delta):
	progress_bar.value = RunManager.assimilation
	percent_label.text = str(roundi(RunManager.assimilation)) + "%"
