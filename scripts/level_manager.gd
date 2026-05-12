extends Node2D
# LevelManager — Loads chapter data, spawns enemies, tracks objectives

@onready var player = $Player
@onready var skeleton_scene = preload("res://scenes/skeleton.tscn")

var chapter_data: Dictionary = {}
var enemies_remaining := 0

func _ready():
	# Load chapter 001 by default
	ChapterDatabase.set_current_chapter("act01_ch001")
	chapter_data = ChapterDatabase.get_current_chapter()
	
	if chapter_data.is_empty():
		push_error("No chapter data loaded")
		return
	
	# Setup scene
	_setup_level()
	
	# Add mobile controls
	var mobile_scene = load("res://scenes/mobile_controls.tscn")
	if mobile_scene:
		add_child(mobile_scene.instantiate())
	
	# Update UI
	$Objective.text = "Objective: " + chapter_data.get("objective", "Defeat enemies!")
	$LevelLabel.text = chapter_data.get("title", "Level 1")
	
	# Set background color
	var bg = chapter_data.get("background_color", [0.08, 0.1, 0.12])
	$ColorRect.color = Color(bg[0], bg[1], bg[2])
	
	print("Chapter loaded: %s" % chapter_data.get("title", "?"))

func _setup_level():
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
	
	enemies_remaining = 0
	for child in get_children():
		if child.is_in_group("enemy"):
			enemies_remaining += 1
	
	GameState.reset_chapter_state()
	GameState.chapter_kills = 0

func _spawn_enemy(type: String, pos: Vector2, stats: Dictionary):
	if type != "skeleton":
		return  # Only skeleton implemented
	
	var inst = skeleton_scene.instantiate()
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
	
	if chapter_data.get("type", "combat") == "combat":
		var live_enemies := 0
		for child in get_children():
			if child.is_in_group("enemy") and not child.is_dead:
				live_enemies += 1
		
		if live_enemies == 0 and enemies_remaining > 0:
			_objective_complete()
			enemies_remaining = 0  # Prevent double-trigger

func _objective_complete():
	print("Chapter complete! Loading next...")
	GameState.complete_current_chapter()
	
	# Show completion dialog
	$Objective.text = "COMPLETED! — Press R to restart"
	$Objective.modulate = Color.GREEN
	
	# Auto-save is done in GameState
	
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()