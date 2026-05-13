extends Control
# PauseMenu — Runtime pause overlay with resume/restart/quit
# Instantiated by LevelManager, creates its own UI nodes.

var is_paused := false
var is_changing_scene := false

# UI refs
var bg: ColorRect
var vbox: VBoxContainer
var resume_btn: Button
var restart_btn: Button
var mute_btn: Button
var quit_btn: Button

# Called by parent scene
func setup(parent: Node):
	parent.add_child(self)
	_build_ui()
	visible = false

func _build_ui():
	# Full-screen overlay behind UI
	anchor_right = 1.0
	anchor_bottom = 1.0
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	mouse_filter = Control.MOUSE_FILTER_STOP  # Block clicks behind
	
	# Semi-transparent background
	bg = ColorRect.new()
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.grow_horizontal = Control.GROW_DIRECTION_BOTH
	bg.grow_vertical = Control.GROW_DIRECTION_BOTH
	bg.color = Color(0.05, 0.06, 0.08, 0.85)
	add_child(bg)
	
	# Container hierarchy
	var center = CenterContainer.new()
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	center.grow_horizontal = Control.GROW_DIRECTION_BOTH
	center.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(center)
	
	vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.add_theme_font_size_override("font_size", 28)
	title.text = "|| PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(spacer)
	
	# Resume
	resume_btn = _make_btn("▶  Resume", "_on_resume")
	vbox.add_child(resume_btn)
	
	# Restart
	restart_btn = _make_btn("↻  Restart Chapter", "_on_restart")
	vbox.add_child(restart_btn)
	
	# Mute toggle
	mute_btn = _make_btn("🔇  Mute", "_on_mute")
	vbox.add_child(mute_btn)
	
	# Quit to title
	quit_btn = _make_btn("✕  Quit to Title", "_on_quit")
	vbox.add_child(quit_btn)
	
	# Bottom hint
	var hint = Label.new()
	hint.add_theme_font_size_override("font_size", 9)
	hint.modulate = Color(0.5, 0.5, 0.5, 1)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.text = "ESC = Pause | R = Restart | M = Mute"
	vbox.add_child(hint)

func _make_btn(text: String, callback: String) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(200, 44)
	btn.add_theme_font_size_override("font_size", 14)
	btn.text = text
	btn.pressed.connect(Callable(self, callback))
	return btn

func toggle():
	if is_changing_scene:
		return
	if is_paused:
		_resume()
	else:
		_pause()

func _pause():
	is_paused = true
	Engine.time_scale = 0
	visible = true
	resume_btn.grab_focus()
	_update_mute_label()
	z_index = 100

func _resume():
	is_paused = false
	Engine.time_scale = 1
	visible = false

func _on_resume():
	_resume()

func _on_restart():
	is_changing_scene = true
	Engine.time_scale = 1
	AudioManager.play_sfx("ui_click")
	get_tree().reload_current_scene()

func _on_mute():
	AudioManager.set_volume(0.0 if AudioManager.master_volume > 0.0 else 0.8)
	_update_mute_label()

func _update_mute_label():
	mute_btn.text = "🔇  Mute" if AudioManager.master_volume > 0.0 else "🔊  Unmute"

func _on_quit():
	is_changing_scene = true
	Engine.time_scale = 1
	AudioManager.play_sfx("ui_click")
	AudioManager.stop_bgm(0.5)
	# Clear game session state
	GameState.reset_chapter_state()
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

# Input handling — catch ESC while paused to prevent double-toggle
func _input(event):
	if not is_paused:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_resume()
		get_viewport().set_input_as_handled()
