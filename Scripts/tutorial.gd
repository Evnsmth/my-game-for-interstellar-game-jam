extends Node2D

signal start_enemy

@onready var instruction_label: Label = $CanvasLayer/InstructionLabel
@onready var player = $Player

enum TutorialStep {
	MOVE,
	SHOOT,
	DASH,
	DASH2,
	ENEMY,
	CONSUME,
	EXIT
}

var current_step := TutorialStep.MOVE
var enemy_defeated = false

func _input(event: InputEvent) -> void:
	if(not current_step == TutorialStep.ENEMY):
		if event.is_action_pressed("next"):
			next_step()
	elif(enemy_defeated == true):
		next_step()

func next_step():
	current_step += 1

	match current_step:
		TutorialStep.SHOOT:
			instruction_label.text = "Hold LEFT CLICK to shoot (Press N to continue)"

		TutorialStep.DASH:
			instruction_label.text = "Shift, Space, and Right click are all dash, choose your preference (Press N to continue)"

		TutorialStep.DASH2:
			instruction_label.text = "Getting used to the dash is important for evading enemies (Press N to continue)"

		TutorialStep.ENEMY:
			start_enemy.emit()
			instruction_label.text = "Defeat the enemy slime (Press N to continue after slime has been defeated)"

		TutorialStep.CONSUME:
			instruction_label.text = "Approach the puddle, read its effects, and consume (Press E) it (Press N to continue)"

		TutorialStep.EXIT:
			instruction_label.text = "Enter the trapdoor (Press Enter) to finish the tutorial"
