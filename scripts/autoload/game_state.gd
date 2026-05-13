extends Node
# GameState — Persistent save/load + progression tracking
# Handles chapter unlocks, player stats, settings

const SAVE_FILE := "user://swordjin_save.json"

# Player Progress
var current_act: int = 1
var current_chapter: int = 1
var completed_chapters: Array = []
var player_level: int = 1
var player_xp: int = 0
var player_gold: int = 0
var unlocked_weapons: Array = []
var unlocked_skills: Array = []

# Chapter State (runtime only)
var chapter_kills: int = 0
var chapter_objectives_met: Dictionary = {}
var is_paused: bool = false

func _ready():
	load_game()
	print("GameState loaded — Act %d, Chapter %d" % [current_act, current_chapter])

func save_game():
	var data := {
		"version": "1.0",
		"current_act": current_act,
		"current_chapter": current_chapter,
		"completed_chapters": completed_chapters,
		"player_level": player_level,
		"player_xp": player_xp,
		"player_gold": player_gold,
		"unlocked_weapons": unlocked_weapons,
		"unlocked_skills": unlocked_skills
	}
	
	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		print("Game saved")
	else:
		push_error("Failed to save game")

func load_game():
	if not FileAccess.file_exists(SAVE_FILE):
		print("No save file — starting fresh")
		return
	
	var file := FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file == null:
		push_error("Cannot read save file")
		return
	
	var text := file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var err := json.parse(text)
	if err != OK:
		push_error("Save file corrupt — starting fresh")
		return
	
	var data = json.data
	if data is Dictionary:
		current_act = data.get("current_act", 1)
		current_chapter = data.get("current_chapter", 1)
		completed_chapters = data.get("completed_chapters", [])
		player_level = data.get("player_level", 1)
		player_xp = data.get("player_xp", 0)
		player_gold = data.get("player_gold", 0)
		unlocked_weapons = data.get("unlocked_weapons", [])
		unlocked_skills = data.get("unlocked_skills", [])
		print("Save loaded successfully")

func complete_current_chapter():
	var chapter_id := "act%02d_ch%03d" % [current_act, current_chapter]
	if not completed_chapters.has(chapter_id):
		completed_chapters.append(chapter_id)
	
	# Check for next chapter unlock
	var next_chapter_id: String = ChapterDatabase.get_current_chapter().get("next_chapter", "")
	if next_chapter_id != "":
		if ChapterDatabase.chapters.has(next_chapter_id):
			ChapterDatabase.chapters[next_chapter_id]["is_unlocked"] = true
	
	# Apply rewards
	var rewards = ChapterDatabase.get_current_chapter().get("rewards", {})
	player_xp += rewards.get("xp", 0)
	if rewards.has("unlock_weapon"):
		unlocked_weapons.append(rewards.unlock_weapon)
	if rewards.has("unlock_skill"):
		unlocked_skills.append(rewards.unlock_skill)
	
	_save_indexeddb()
	save_game()

func get_level_xp_requirement(level: int) -> int:
	# Simple quadratic XP curve
	return level * level * 100

func add_xp(amount: int):
	player_xp += amount
	var required := get_level_xp_requirement(player_level)
	while player_xp >= required:
		player_xp -= required
		player_level += 1
		print("LEVEL UP! Now level %d" % player_level)
		required = get_level_xp_requirement(player_level)

func is_chapter_unlocked(act: int, chapter: int) -> bool:
	var id := "act%02d_ch%03d" % [act, chapter]
	if ChapterDatabase.chapters.has(id):
		return ChapterDatabase.chapters[id].get("is_unlocked", false)
	return false

func reset_chapter_state():
	chapter_kills = 0
	chapter_objectives_met.clear()

# Web export: ensure immediate flush to IndexedDB persistence
func _save_indexeddb():
	if OS.has_feature("web") and OS.has_feature("wasm"):
		# Godot's VFS persists on page unload, but we force a sync now
		JavaScriptBridge.eval("""
			if (typeof Module !== 'undefined' && Module.FS && Module.FS.syncfs) {
				Module.FS.syncfs(false, function(err) {
					if (err) console.error('Save sync error:', err);
				});
			}
		""")
		print("IndexedDB sync requested")

class ChapterProgress:
	var chapter_id: String
	var best_time: float
	var stars: int = 0  # 0-3 rating
	var completed: bool = false