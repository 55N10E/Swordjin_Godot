"""Hit stop (freeze frames) — pauses game time briefly on impact for weightier feel."""
extends Node

class_name HitStop

@export var default_freeze_ms: int = 80
@export var heavy_freeze_ms: int = 150
@export var max_freeze_ms: int = 250

var _remaining_ms: float = 0.0
var _is_freezing: bool = false

func trigger(freeze_ms: int = default_freeze_ms) -> void:
	freeze_ms = clampi(freeze_ms, 0, max_freeze_ms)
	if freeze_ms <= 0:
		return
	
	# Accumulate freeze time if already in hit-stop (combo feel)
	_remaining_ms += freeze_ms
	_remaining_ms = minf(_remaining_ms, max_freeze_ms)
	
	if not _is_freezing:
		_is_freezing = true
		Engine.time_scale = 0.0
		_process_freeze()

func _process_freeze() -> void:
	await get_tree().create_timer(_remaining_ms / 1000.0, true, false, true).timeout
	Engine.time_scale = 1.0
	_is_freezing = false
	_remaining_ms = 0.0

func trigger_light() -> void:
	trigger(default_freeze_ms)

func trigger_heavy() -> void:
	trigger(heavy_freeze_ms)
