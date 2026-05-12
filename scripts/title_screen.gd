extends Control
# TitleScreen — Entry point: start, continue, chapter select
# ChapterManager is embedded; its Start button already changes scene to main.tscn

@onready var start_btn = $CenterContainer/VBoxContainer/StartButton
@onready var continue_btn = $CenterContainer/VBoxContainer/ContinueButton
@onready var select_btn = $CenterContainer/VBoxContainer/SelectButton
@onready var chm = $ChapterManager

func _ready():
	start_btn.grab_focus()
	
	# Start title music
	AudioManager.play_bgm("bgm_title", 1.0, true)
	
	# Disable continue if no progress
	if GameState.completed_chapters.is_empty():
		continue_btn.disabled = true
		continue_btn.modulate = Color.GRAY

func _on_start_pressed():
	ChapterDatabase.set_current_chapter("act01_ch001")
	GameState.reset_chapter_state()
	AudioManager.play_sfx("ui_click")
	AudioManager.stop_bgm(0.5)
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_continue_pressed():
	var id = _get_last_chapter()
	ChapterDatabase.set_current_chapter(id)
	GameState.reset_chapter_state()
	AudioManager.play_sfx("ui_click")
	AudioManager.stop_bgm(0.5)
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_select_pressed():
	AudioManager.play_sfx("ui_click")
	chm.show_manager()
	# Hide our buttons while chapter manager is open
	$CenterContainer.visible = false
	# Re-show when back is pressed
	var back_btn = chm.get_node("MarginContainer/VBoxContainer/HBoxContainer/BackButton")
	back_btn.pressed.connect(_on_chapter_back, CONNECT_ONE_SHOT)

func _on_chapter_back():
	$CenterContainer.visible = true
	start_btn.grab_focus()

func _get_last_chapter() -> String:
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
	var next = ChapterDatabase.chapters.get(last_id, {}).get("next_chapter", "")
	if not next.is_empty():
		return next
	return last_id
