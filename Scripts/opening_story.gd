extends Control

@onready var story_timer: Timer = $StoryTimer


var current_card := 0

var story_texts = [
	"The life of a slime is simple. Kill, consume, and assimilate everything it came across",
	"But underneath the surface, something greater was stirring...",
	"At the bottom of the dungeon, something waits, something stronger that anything found on the surface",
	"Descend. Consume. Become the strongest."
]


func _ready() -> void:
	story_timer.start(3.0)
	show_card()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip"):
		start_game()


func show_card() -> void:
	$StoryText.text = story_texts[current_card]


func next_card() -> void:
	current_card += 1

	if current_card >= story_texts.size():
		start_game()
		return

	show_card()


func start_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_story_timer_timeout() -> void:
	story_timer.start(3.0)
	next_card()
