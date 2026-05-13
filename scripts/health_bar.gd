extends Control

@export var max_health: int = 100
var current_health: int = 100

@onready var fill = $Fill

func _ready():
	update_health(current_health, max_health)

func update_health(new_health: int, new_max: int = -1):
	if new_max > 0:
		max_health = new_max
	current_health = clampi(new_health, 0, max_health)
	
	var ratio = float(current_health) / float(max_health) if max_health > 0 else 0.0
	fill.size.x = size.x * ratio
	
	# Color shift: green → yellow → red
	if ratio > 0.6:
		fill.color = Color(0.2, 0.9, 0.2, 1)  # Green
	elif ratio > 0.3:
		fill.color = Color(0.9, 0.9, 0.2, 1)  # Yellow
	else:
		fill.color = Color(0.9, 0.2, 0.2, 1)  # Red
