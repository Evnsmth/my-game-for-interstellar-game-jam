extends Control


@onready var story_timer: Timer = $StoryTimer


var current_card := 0

var story_texts = [
	"You turn your back to the final slime",
	"The Singularity is in your reach...",
	"But you leave it behind",
	"You entered the dungeon as yourself",
	"And that is how you'll leave it",
	"CYCLE BROKEN",
	"Thanks for playing!"
]


func _ready() -> void:
	story_timer.start(3.05)
	show_card()


func show_card() -> void:
	$StoryText.text = story_texts[current_card]


func next_card() -> void:
	current_card += 1

	if current_card >= story_texts.size():
		RunManager.start_new_run()
		get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
		return

	show_card()


func _on_story_timer_timeout() -> void:
	story_timer.start(3.0)
	next_card()
