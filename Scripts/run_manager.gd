extends Node


var puddle_consumed: int = 0
var total_floors: int = 10

var assimilation: float = 0.0

func start_new_run():
	puddle_consumed = 0
	assimilation = 0.0

func consume_puddle():
	puddle_consumed += 1
	update_assimilation()

func update_assimilation():
	if total_floors <= 0:
		assimilation = 0.0
		return

	assimilation = (float(puddle_consumed) / float(total_floors)) * 100.0
	assimilation = clamp(assimilation, 0.0, 100.0)
