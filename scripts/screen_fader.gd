extends CanvasLayer
# ScreenFader — fade to/from black transitions
# Survives scene reloads as autoload

@onready var rect: ColorRect = $ColorRect

func _ready():
	# Start transparent
	rect.modulate = Color.TRANSPARENT

func fade_to_black(duration: float = 0.5) -> Signal:
	var tween := create_tween()
	tween.tween_property(rect, "modulate", Color.BLACK, duration)
	return tween.finished

func fade_from_black(duration: float = 0.5) -> Signal:
	var tween := create_tween()
	tween.tween_property(rect, "modulate", Color.TRANSPARENT, duration)
	return tween.finished

func flash_white(duration: float = 0.15) -> Signal:
	rect.modulate = Color.WHITE
	var tween := create_tween()
	tween.tween_property(rect, "modulate", Color.TRANSPARENT, duration)
	return tween.finished
