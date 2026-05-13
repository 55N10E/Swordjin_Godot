extends Node2D
# DamageNumber — floats text up and fades it out
# Call setup(amount, color) after adding to scene

var _tween: Tween = null

func setup(amount: int, base_color := Color.RED):
	# Random horizontal offset so overlapping numbers don't stack
	position.x += randf_range(-8, 8)
	
	# Find label child
	var label := $Label as Label
	if not label:
		return
	
	label.text = str(amount)
	label.self_modulate = base_color
	
	# Animate: float up + fade out
	_tween = create_tween().set_parallel()
	_tween.tween_property(self, "position:y", position.y - 36, 0.9)
	
	var fade = create_tween()
	fade.tween_property(label, "self_modulate:a", 0.0, 0.7).set_delay(0.2)
	fade.tween_callback(_cleanup)

func setup_heal(amount: int):
	setup(amount, Color.GREEN)

func _cleanup():
	if is_instance_valid(self):
		queue_free()
