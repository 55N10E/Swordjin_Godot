extends CanvasLayer
# Mobile touch controls for Swordjin PWA
# Works alongside keyboard for desktop testing

@onready var joystick_base = $JoystickBase
@onready var joystick_knob = $JoystickBase/JoystickKnob
@onready var attack_btn = $AttackButton
@onready var skill1_btn = $Skill1Button

var joystick_touch_index := -1
var joystick_radius := 48.0
var joystick_center: Vector2
var is_mobile := false

func _ready():
	# Detect mobile by display size or touch availability
	is_mobile = DisplayServer.is_touchscreen_available() or OS.get_name() in ["Android", "iOS"]
	if not is_mobile and OS.has_feature("web"):
		# Web export: check user agent via JavaScript
		is_mobile = JavaScriptBridge.eval(
			"/Mobi|Android|iPhone|iPad/i.test(navigator.userAgent)"
		) if OS.has_feature("web") else false
	
	if not is_mobile:
		# Desktop: hide mobile controls
		joystick_base.visible = false
		attack_btn.visible = false
		skill1_btn.visible = false
		return
	
	joystick_center = joystick_base.global_position + Vector2(joystick_radius, joystick_radius)
	
	# Connect buttons
	attack_btn.pressed.connect(func(): _emit_action("attack", true))
	attack_btn.button_up.connect(func(): _emit_action("attack", false))
	skill1_btn.pressed.connect(func(): _emit_action("skill1", true))
	skill1_btn.button_up.connect(func(): _emit_action("skill1", false))
	
	print("Mobile controls active")

func _input(event):
	if not is_mobile:
		return
		
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch):
	var touch_pos = event.position
	
	# Check if touch is in joystick area (left half)
	if touch_pos.x < get_viewport().get_visible_rect().size.x * 0.4:
		if event.pressed and joystick_touch_index == -1:
			joystick_touch_index = event.index
			joystick_center = touch_pos
			joystick_base.global_position = touch_pos - Vector2(joystick_radius, joystick_radius)
			joystick_knob.position = Vector2(joystick_radius, joystick_radius)
			joystick_base.visible = true
		elif not event.pressed and event.index == joystick_touch_index:
			joystick_touch_index = -1
			joystick_base.visible = false
			_set_movement(Vector2.ZERO)

func _handle_drag(event: InputEventScreenDrag):
	if event.index != joystick_touch_index:
		return
		
	var touch_pos = event.position
	var offset = touch_pos - joystick_center
	var distance = offset.length()
	
	if distance > joystick_radius:
		offset = offset.normalized() * joystick_radius
		
	joystick_knob.position = Vector2(joystick_radius, joystick_radius) + offset
	
	# Normalize -1..1 analog output
	var input_dir = offset / joystick_radius
	_set_movement(input_dir)

func _set_movement(dir: Vector2):
	# Map to Input actions
	Input.action_press("move_right", clamp(dir.x, 0, 1))
	Input.action_press("move_left", clamp(-dir.x, 0, 1))
	Input.action_press("move_down", clamp(dir.y, 0, 1))
	Input.action_press("move_up", clamp(-dir.y, 0, 1))
	
	# Release if near zero
	if dir.x > -0.1:
		Input.action_release("move_left")
	if dir.x < 0.1:
		Input.action_release("move_right")
	if dir.y > -0.1:
		Input.action_release("move_up")
	if dir.y < 0.1:
		Input.action_release("move_down")

func _emit_action(action_name: String, pressed: bool):
	if pressed:
		Input.action_press(action_name)
	else:
		Input.action_release(action_name)