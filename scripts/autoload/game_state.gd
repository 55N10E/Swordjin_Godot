extends Node
# GameState — Persistent save/load + progression tracking
# v0.60 — weapon stat differentiation, equipped weapon tracking

const SAVE_FILE := "user://swordjin_save.json"

# Weapon definitions — unlocked weapons auto-equip if better
const WEAPON_STATS := {
	"broken_sword":    {"damage": 8,  "cooldown": 0.40, "description": "A rusted relic. Barely sharp."},
	"steel_dagger":    {"damage": 12, "cooldown": 0.30, "description": "Merchant's gift. Light and lethal."},
	"captains_blade":  {"damage": 15, "cooldown": 0.50, "description": "A commander's weapon. Heavy but ruthless."},
}

# Player Progress
var current_act: int = 1
var current_chapter: int = 1
var completed_chapters: Array = []
var player_level: int = 1
var player_xp: int = 0
var player_gold: int = 0
var unlocked_weapons: Array = []
var unlocked_skills: Array = []
var equipped_weapon: String = "broken_sword"  # default starting weapon

# Gate Key mechanic (Ch004)
var has_gate_key := false

# Chapter State (runtime only)
var chapter_kills: int = 0
var chapter_objectives_met: Dictionary = {}
var is_paused: bool = false

# v0.58 — health persistence (so "Continue" works correctly)
var saved_health: int = 100
var saved_max_health: int = 100

func _ready():
	load_game()
	print("GameState loaded — Act %d, Chapter %d, Level %d, key=%s" % [current_act, current_chapter, player_level, has_gate_key])

func save_game():
	var data := {
		"version": "1.1",
		"current_act": current_act,
		"current_chapter": current_chapter,
		"completed_chapters": completed_chapters,
		"player_level": player_level,
		"player_xp": player_xp,
		"player_gold": player_gold,
		"unlocked_weapons": unlocked_weapons,
		"unlocked_skills": unlocked_skills,
		"equipped_weapon": equipped_weapon,
		"saved_health": saved_health,
		"saved_max_health": saved_max_health,
		"has_gate_key": has_gate_key
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
		equipped_weapon = data.get("equipped_weapon", "broken_sword")
		if equipped_weapon not in unlocked_weapons:
			equipped_weapon = "broken_sword"
		saved_health = data.get("saved_health", 100)
		saved_max_health = data.get("saved_max_health", 100)
		has_gate_key = data.get("has_gate_key", false)
		print("Save loaded — HP %d/%d, weapon: %s, key=%s" % [saved_health, saved_max_health, equipped_weapon, has_gate_key])

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
		_auto_equip_best_weapon()
	if rewards.has("unlock_skill"):
		unlocked_skills.append(rewards.unlock_skill)
	
	# Heal 25 HP between chapters (and cap at max)
	saved_health = mini(saved_health + 25, saved_max_health)
	
	_save_indexeddb()
	save_game()

func get_level_xp_requirement(level: int) -> int:
	# Quadratic XP curve
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

func _auto_equip_best_weapon():
	var best_weapon := "broken_sword"
	var best_dmg: int = 0
	for weapon_id in unlocked_weapons:
		if weapon_id in WEAPON_STATS:
			var dmg: int = WEAPON_STATS[weapon_id].get("damage", 0)
			if dmg > best_dmg:
				best_dmg = dmg
				best_weapon = weapon_id
	if best_weapon != equipped_weapon:
		equipped_weapon = best_weapon
		print("Auto-equipped: %s (DMG %d, CD %.2fs)" % [equipped_weapon, WEAPON_STATS[equipped_weapon].damage, WEAPON_STATS[equipped_weapon].cooldown])

func get_weapon_stats(weapon_id: String = equipped_weapon) -> Dictionary:
	if weapon_id in WEAPON_STATS:
		return WEAPON_STATS[weapon_id]
	return WEAPON_STATS["broken_sword"]

class ChapterProgress:
	var chapter_id: String
	var best_time: float
	var stars: int = 0  # 0-3 rating
	var completed: bool = false
