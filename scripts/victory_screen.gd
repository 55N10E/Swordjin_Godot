extends CanvasLayer
# VictoryScreen — Chapter complete overlay
# v0.66: Shows XP gain + gold earned + weapon unlock with Continue / Chapter Select buttons

signal next_chapter_pressed
signal chapter_select_pressed

@onready var panel = $Panel
@onready var title_label = $Panel/VBoxContainer/TitleLabel
@onready var xp_label = $Panel/VBoxContainer/XPLabel
@onready var gold_label = $Panel/VBoxContainer/GoldLabel
@onready var reward_label = $Panel/VBoxContainer/RewardLabel
@onready var continue_btn = $Panel/VBoxContainer/HBoxContainer/ContinueButton
@onready var select_btn = $Panel/VBoxContainer/HBoxContainer/SelectButton
@onready var animation = $AnimationPlayer

var _has_next_chapter: bool = false

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  # Run while paused
	continue_btn.pressed.connect(_on_continue)
	select_btn.pressed.connect(_on_select)

func show_victory(chapter_title: String, xp_gained: int, gold_gained: int = 0, reward_weapon: String = "", reward_skill: String = ""):
	# Pause the game
	get_tree().paused = true
	
	# Title
	title_label.text = "VICTORY: " + chapter_title
	
	# XP line
	xp_label.text = "XP Gained: " + str(xp_gained)
	
	# Gold line (yellow #FFD700)
	gold_label.text = "Gold Earned: " + str(gold_gained)
	gold_label.add_theme_color_override("font_color", Color(1.0, 0.843, 0.0))  # #FFD700
	gold_label.visible = true
	
	# Reward line
	var reward_parts: Array[String] = []
	if not reward_weapon.is_empty():
		reward_parts.append("Weapon: " + _format_name(reward_weapon))
	if not reward_skill.is_empty():
		reward_parts.append("Skill: " + _format_name(reward_skill))
	
	if reward_parts.is_empty():
		reward_label.text = ""
		reward_label.visible = false
	else:
		reward_label.text = "Unlocked: " + " | ".join(reward_parts)
		reward_label.visible = true
	
	# Show / hide continue based on whether there's a next chapter
	continue_btn.visible = _has_next_chapter
	
	# Fade in
	visible = true
	modulate = Color.TRANSPARENT
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate", Color.WHITE, 0.4)
	
	AudioManager.play_sfx("level_complete")

func _format_name(snake_case: String) -> String:
	var parts = snake_case.split("_")
	var out: Array[String] = []
	for p in parts:
		out.append(p.capitalize())
	return " ".join(out)

func _on_continue():
	AudioManager.play_sfx("ui_click")
	hide_victory()
	next_chapter_pressed.emit()

func _on_select():
	AudioManager.play_sfx("ui_click")
	hide_victory()
	chapter_select_pressed.emit()

func hide_victory():
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3)
	await tween.finished
	visible = false
	get_tree().paused = false