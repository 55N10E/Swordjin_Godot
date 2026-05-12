extends CanvasLayer
# ChapterManager — Chapter select / title screen overlay
# Displays acts + chapters as a grid; start or continue game

@onready var title_label = $MarginContainer/VBoxContainer/TitleLabel
@onready var act_tabs = $MarginContainer/VBoxContainer/ActTabs
@onready var grid = $MarginContainer/VBoxContainer/GridContainer
@onready var info_label = $MarginContainer/VBoxContainer/InfoLabel
@onready var start_button = $MarginContainer/VBoxContainer/HBoxContainer/StartButton
@onready var back_button = $MarginContainer/VBoxContainer/HBoxContainer/BackButton
@onready var progress_bar = $MarginContainer/VBoxContainer/ProgressBar

var selected_chapter_id := ""
var current_act := 1
var max_act_buttons := 1  # Increases as acts are cleared

func _ready():
	visible = false
	_act_buttons_setup()
	_refresh_chapters()
	_update_progress()

func _act_buttons_setup():
	for i in range(1, 11):
		var btn = Button.new()
		btn.name = "Act%d" % i
		btn.text = "Act %d" % i
		btn.toggle_mode = true
		btn.pressed.connect(_on_act_selected.bind(i))
		act_tabs.add_child(btn)
		# Only Act 1 unlocked initially; others unlock by progress
		if i <= max_act_buttons:
			btn.disabled = false
		else:
			btn.disabled = true

func show_manager():
	visible = true
	max_act_buttons = _get_max_unlocked_act()
	for i in range(1, 11):
		var btn = act_tabs.get_node("Act%d" % i)  
		btn.disabled = i > max_act_buttons
	_refresh_chapters()
	_update_progress()

func hide_manager():
	visible = false

func _get_max_unlocked_act() -> int:
	var max_act := 1
	for id in ChapterDatabase.chapters:
		var ch = ChapterDatabase.chapters[id]
		if ch.get("is_unlocked", false):
			var act = ch.get("act", 1)
			if act > max_act:
				max_act = act
	return max_act

func _on_act_selected(act: int):
	current_act = act
	# Deselect others
	for i in range(1, 11):
		var btn = act_tabs.get_node("Act%d" % i)
		btn.set_pressed_no_signal(i == act)
	_refresh_chapters()

func _refresh_chapters():
	# Clear grid
	for child in grid.get_children():
		child.queue_free()
	
	var act_chapters := []
	for id in ChapterDatabase.chapters.keys():
		var ch = ChapterDatabase.chapters[id]
		if ch.get("act", 1) == current_act:
			act_chapters.append(ch)
	
	act_chapters.sort_custom(func(a, b): return a.get("chapter", 0) < b.get("chapter", 0))
	
	for ch in act_chapters:
		var id = ch.get("chapter_id", "")
		var title = ch.get("title", "Untitled")
		var unlocked = ch.get("is_unlocked", false)
		var completed = GameState.completed_chapters.has(id)
		
		var btn = Button.new()
		btn.text = "%d. %s" % [ch.get("chapter", 0), title]
		btn.custom_minimum_size = Vector2(160, 40)
		btn.disabled = not unlocked
		
		if completed:
			btn.modulate = Color.GREEN
		elif unlocked:
			btn.modulate = Color.WHITE
		else:
			btn.modulate = Color.GRAY
		
		btn.pressed.connect(_on_chapter_selected.bind(ch))
		grid.add_child(btn)

func _on_chapter_selected(ch: Dictionary):
	selected_chapter_id = ch.get("chapter_id", "")
	var title = ch.get("title", "")
	var obj = ch.get("objective", "")
	var est = ch.get("playtime_estimate_minutes", 0)
	info_label.text = "🗡 %s\n📜 %s\n⏱ %d min" % [title, obj, est]
	start_button.disabled = false

func _on_start_button_pressed():
	if selected_chapter_id.is_empty():
		return
	ChapterDatabase.set_current_chapter(selected_chapter_id)
	GameState.reset_chapter_state()
	# If main.tscn is dynamic we can also pass chapter data
	# For now, level_manager reads current_chapter on _ready
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_back_button_pressed():
	hide_manager()

func _update_progress():
	var total = ChapterDatabase.chapters.size()
	var done = GameState.completed_chapters.size()
	progress_bar.value = total > 0 ? (float(done) / float(total)) * 100.0 : 0.0
	progress_bar.tooltip_text = "%d / %d chapters" % [done, total]

func _on_continue_button_pressed():
	# Load most recent unlocked chapter
	var id = "act%02d_ch%03d" % [GameState.current_act, GameState.current_chapter]
	if ChapterDatabase.chapters.has(id):
		selected_chapter_id = id
		_on_start_button_pressed()
