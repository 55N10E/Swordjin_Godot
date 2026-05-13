extends Node

var shake_intensity := 0.0
var shake_duration := 0.0
var camera: Camera2D

func _get_camera():
	if camera == null:
		var cameras = get_tree().get_nodes_in_group("main_camera")
		if cameras.size() > 0:
			camera = cameras[0]
	return camera

func shake(intensity: float, duration: float):
	shake_intensity = intensity
	shake_duration = duration

func _process(delta):
	camera = _get_camera()
	if camera == null:
		return
	
	if shake_duration <= 0:
		if camera.position != Vector2.ZERO:
			camera.position = Vector2.ZERO
		return
	
	shake_duration -= delta
	if shake_duration <= 0:
		camera.position = Vector2.ZERO
		return
	
	var offset = Vector2(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)
	camera.position = offset
