extends Node


var current_floor: int = 0
var total_floors: int = 10

var assimilation: float = 0.0

func start_new_run():
	current_floor = 0
	assimilation = 0.0

func complete_floor():
	current_floor += 1
	update_assimilation()

func update_assimilation():
	if total_floors <= 0:
		assimilation = 0.0
		return

	assimilation = (float(current_floor) / float(total_floors)) * 100.0
	assimilation = clamp(assimilation, 0.0, 100.0)
