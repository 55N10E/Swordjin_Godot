extends Node2D
# LevelManager — Loads chapter data, spawns enemies, tracks objectives

@onready var player = $Player
@onready var skeleton_scene = preload("res://scenes/skeleton.tscn")
@onready var captain_scene = preload("res://scenes/skeleton_captain.tscn")
@onready var archer_scene = preload("res://scenes/skeleton_archer.tscn")
@onready var merchant_scene = preload("res://scenes/merchant_ally.tscn")

var chapter_data: Dictionary = {}
var enemies_remaining := 0
var dialogue_triggered := {}
var pause_menu: Control

func _ready():
	# Load chapter 001 by default
	ChapterDatabase.set_current_chapter("act01_ch001")
	chapter_data = ChapterDatabase.get_current_chapter()
	
	if chapter_data.is_empty():
		push_error("No chapter data loaded")
		return
	
	# Setup scene
	_setup_level()
	
	# Add pause menu
	pause_menu = load("res://scripts/pause_menu.gd").new()
	pause_menu.setup(self)
	
	# Add mobile controls
	var mobile_scene = load("res://scenes/mobile_controls.tscn")
	if mobile_scene:
		add_child(mobile_scene.instantiate())
	
	# Add dialogue manager (from packed scene)
	var dlg_scene = load("res://scenes/dialogue_manager.tscn")
	if dlg_scene:
		var dlg_instance = dlg_scene.instantiate()
		dlg_instance.name = "DialogueManager"
		add_child(dlg_instance)
	
	# Add chapter manager (hidden by default)
	var chm_scene = load("res://scenes/chapter_manager.tscn")
	if chm_scene:
		var chm_instance = chm_scene.instantiate()
		chm_instance.name = "ChapterManager"
		add_child(chm_instance)
	
	_dialogue_start()
	
	# Update UI
	$Objective.text = "Objective: " + chapter_data.get("objective", "Defeat enemies!")
	$LevelLabel.text = chapter_data.get("title", "Level 1")
	
	# Set background color
	var bg = chapter_data.get("background_color", [0.08, 0.1, 0.12])
	$ColorRect.color = Color(bg[0], bg[1], bg[2])
	
	print("Chapter loaded: %s" % chapter_data.get("title", "?"))
	print("Press C for chapter select | M for mute")

func _dialogue_start():
	var dlg = get_node("DialogueManager")
	if not dlg:
		dialogue_triggered["start"] = true
		return
	var dialogue = chapter_data.get("dialogue", [])
	if not dialogue.is_empty():
		dlg.load_dialogue(dialogue)
		dlg.dialogue_ended.connect(_on_dialogue_ended_start, CONNECT_ONE_SHOT)
		await get_tree().create_timer(0.5).timeout
		dlg.play_dialogue_for_trigger("start")
	else:
		# No dialogue, enable combat immediately
		dialogue_triggered["start"] = true

func _on_dialogue_ended_start():
	dialogue_triggered["start"] = true
	AudioManager.play_bgm("bgm_battle", 1.0, true)

func _setup_level():
	# Apply saved health from GameState
	if player and GameState.saved_health > 0:
		player.max_health = GameState.saved_max_health
		player.health = GameState.saved_health
		player._update_label()
	
	# Clear existing skeletons
	for child in get_children():
		if child.is_in_group("enemy"):
			child.queue_free()
	
	# Spawn from chapter data
	var enemies = chapter_data.get("enemies", [])
	for group in enemies:
		var enemy_type = group.get("type", "skeleton")
		var positions = group.get("positions", [])
		var stats = group.get("stats", {})
		
		for pos_data in positions:
			var pos = Vector2(pos_data.x, pos_data.y)
			_spawn_enemy(enemy_type, pos, stats)
	
	# Spawn allies
	var allies = chapter_data.get("allies", [])
	for ally_data in allies:
		var ally_type = ally_data.get("type", "merchant")
		if ally_type == "merchant" and merchant_scene:
			var ally_inst = merchant_scene.instantiate()
			var apos = ally_data.get("position", {"x": 150, "y": 250})
			ally_inst.position = Vector2(apos.x, apos.y)
			var lines = []
			if ally_data.has("dialogue"):
				var dlg = ally_data["dialogue"]
				for k in ["start", "mid_combat", "objective_complete"]:
					if dlg.has(k):
						lines.append(dlg[k])
				if ally_inst.has_method("_setup"):
					ally_inst._setup(lines)
			add_child(ally_inst)
	
	enemies_remaining = 0
	for child in get_children():
		if child.is_in_group("enemy"):
			enemies_remaining += 1
	
	GameState.reset_chapter_state()
	GameState.chapter_kills = 0

func _spawn_enemy(type: String, pos: Vector2, stats: Dictionary):
	var inst: CharacterBody2D
	if type == "skeleton_captain":
		inst = captain_scene.instantiate()
	elif type == "skeleton_archer":
		inst = archer_scene.instantiate()
	else:
		inst = skeleton_scene.instantiate()
		
	inst.position = pos
	add_child(inst)
	
	# Apply stats
	if stats.has("health"):
		inst.max_health = stats.health
		inst.health = stats.health
	if stats.has("speed"):
		inst.speed = stats.speed
	if stats.has("damage"):
		inst.attack_damage = stats.damage
	
	inst.add_to_group("enemy")
	
	# Connect death signal
	if inst.has_method("_die"):
		# We'll poll in process instead — simpler
		pass

func _process(_delta):
	# Check chapter complete condition
	if chapter_data.is_empty():
		return
	if not dialogue_triggered.get("start", false):
		return  # Wait for start dialogue to finish
	
	if chapter_data.get("type", "combat") == "combat":
		var live_enemies := 0
		for child in get_children():
			if child.is_in_group("enemy") and not child.is_dead:
				live_enemies += 1
		
		if live_enemies == 0 and enemies_remaining > 0:
			enemies_remaining = 0  # Prevent double-trigger
			_objective_complete()

func _objective_complete():
	# Handle "objective_complete" dialogue trigger
	var dlg = get_node("DialogueManager")
	var dialogue = chapter_data.get("dialogue", [])
	var has_completion_dialogue = false
	for entry in dialogue:
		if entry.get("trigger", "") == "objective_complete":
			has_completion_dialogue = true
			break
	
	if has_completion_dialogue and dlg:
		dlg.load_dialogue(dialogue)
		dlg.play_dialogue_for_trigger("objective_complete")
		dlg.dialogue_ended.connect(_on_objective_dialogue_done, CONNECT_ONE_SHOT)
	else:
		_finish_chapter_complete()

func _on_objective_dialogue_done():
	_finish_chapter_complete()

func _finish_chapter_complete():
	# Merchant heal if ally present
	var allies = chapter_data.get("allies", [])
	if not allies.is_empty():
		player.heal(25)
	
	print("Chapter complete! Loading next...")
	AudioManager.play_sfx("level_complete")
	GameState.complete_current_chapter()
	
	# Check if there's a next chapter
	var next = chapter_data.get("next_chapter", "")
	if not next.is_empty():
		ChapterDatabase.set_current_chapter(next)
		$Objective.text = "CHAPTER COMPLETE — Press R to continue"
	else:
		$Objective.text = "CHAPTER COMPLETE! — Press R to restart"
	$Objective.modulate = Color.GREEN
	
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		if pause_menu and pause_menu.is_paused:
			pause_menu._resume()
		get_tree().reload_current_scene()
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if pause_menu:
			pause_menu.toggle()
			get_viewport().set_input_as_handled()
	if event is InputEventKey and event.pressed and event.keycode == KEY_C:
		if pause_menu and pause_menu.is_paused:
			return
		var chm = get_node_or_null("ChapterManager")
		if chm:
			chm.visible = not chm.visible
			if chm.visible:
				chm.show_manager()
			else:
				chm.hide_manager()
	if event is InputEventKey and event.pressed and event.keycode == KEY_M:
		AudioManager.set_volume(0.0 if AudioManager.master_volume > 0.0 else 0.8)
		if pause_menu:
			pause_menu._update_mute_label()