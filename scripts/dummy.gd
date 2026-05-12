extends CharacterBody2D

@export var max_health := 50

var health: int

@onready var label = $Label

func _ready():
	health = max_health
	_update_label()

func take_damage(amount: int):
	health -= amount
	_update_label()
	
	# Flash red
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		_die()

func _update_label():
	if label:
		label.text = "HP: %d/%d" % [health, max_health]

func _die():
	print("Dummy defeated!")
	queue_free()
