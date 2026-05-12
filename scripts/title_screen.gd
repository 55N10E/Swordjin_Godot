extends Control
# TitleScreen — Entry point: start, continue, chapter select

@onready var start_btn = $CenterContainer/VBoxContainer/StartButton
@onready var continue_btn = $CenterContainer/VBoxContainer/ContinueButton
@onready var select_btn = $CenterContainer/VBoxContainer/SelectButton
@onready var chm = $ChapterManager

func _ready():
	# Setup focus navigation
	start_btn.grab_focus()
	
	# Enable/disable continue based on saved state
	continue_btn.disabled = GameState.completed_chapters.is_empty()
	if continue_btn.disabled:
		continue_btn.modulate = Color.GRAY
	
	# Hook ChapterManager start signal
	chm._on_start_button_pressed = func():
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_start_pressed():
	# Start from first chapter
	ChapterDatabase.set_current_chapter("act01_ch001")
	GameState.reset_chapter_state()
	AudioManager.play_sfx("ui_click")
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_continue_pressed():
	# Load most recent progress
	var id = _get_last_chapter()
	ChapterDatabase.set_current_chapter(id)
	GameState.reset_chapter_state()
	AudioManager.play_sfx("ui_click")
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_select_pressed():
	AudioManager.play_sfx("ui_click")
	chm.show_manager()

func _get_last_chapter() -> String:
	# Return last completed or in-progress chapter
	if GameState.completed_chapters.is_empty():
		return "act01_ch001"
	var last_id := ""
	var last_chapter := 0
	for id in GameState.completed_chapters:
		var ch = ChapterDatabase.chapters.get(id, {})
		var ch_num = ch.get("chapter", 0)
		if ch_num >= last_chapter:
			last_chapter = ch_num
			last_id = id
	# Return the NEXT chapter after last completed
	var next = ChapterDatabase.chapters.get(last_id, {}).get("next_chapter", "")
	if not next.is_empty():
		return next
	return last_id
