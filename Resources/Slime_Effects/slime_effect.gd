class_name SlimeEffect
extends Resource


@export_category("Identity")
@export var effect_name: String = "Unnamed Slime"
@export_multiline var description: String = ""

@export_category("Stat Modifiers")
@export var damage_percent: float = 0.0
@export var movement_speed_percent: float = 0.0
@export var fire_rate_percent: float = 0.0
@export var max_health_percent: float = 0.0

@export_category("Appearance")
@export var puddle_texture: Texture2D
