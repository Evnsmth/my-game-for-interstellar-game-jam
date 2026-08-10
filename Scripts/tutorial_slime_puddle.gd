extends Node2D


@onready var sprite: Sprite2D = $Sprite2D
@onready var trapdoor = get_tree().get_first_node_in_group("trapdoor")
@export var slime_effect: SlimeEffect


var player_nearby: Node = null
var can_see_text = false


func _process(_delta: float) -> void:
	if not can_see_text:
		return
	
	if player_nearby != null and Input.is_action_just_pressed("consume"):
		consume()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = body
	


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player_nearby:
		player_nearby = null

func consume():
	trapdoor.open()
	
	queue_free()

func _on_remove_puddles():
	queue_free()
