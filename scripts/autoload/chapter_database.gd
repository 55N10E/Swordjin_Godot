extends Node
# ChapterDatabase — Loads and manages all chapter data
# Populated from JSON files in res://chapters/

var chapters: Dictionary = {}
var current_chapter_data: Dictionary = {}

func _ready():
	_load_all_chapters()

func _load_all_chapters():
	var dir := DirAccess.open("res://chapters/")
	if dir == null:
		push_error("Failed to open chapters directory")
		return
	
	dir.list_dir_begin()
	var act_name := dir.get_next()
	while act_name != "":
		if dir.current_is_dir() and not act_name.begins_with("."):
			_load_act("res://chapters/" + act_name)
		act_name = dir.get_next()
	dir.list_dir_end()
	
	print("Loaded %d chapters" % chapters.size())

func _load_act(path: String):
	var act_dir := DirAccess.open(path)
	if act_dir == null:
		return
	
	act_dir.list_dir_begin()
	var file := act_dir.get_next()
	while file != "":
		if file.ends_with(".json"):
			var chapter_id := file.trim_suffix(".json")
			var data = _load_json(path + "/" + file)
			if data is Dictionary:
				chapters[data.get("chapter_id", chapter_id)] = data
		file = act_dir.get_next()
	act_dir.list_dir_end()

func _load_json(path: String) -> Variant:
	var file_obj := FileAccess.open(path, FileAccess.READ)
	if file_obj == null:
		push_error("Failed to read: " + path)
		return {}
	
	var text := file_obj.get_as_text()
	file_obj.close()
	
	var json = JSON.new()
	var err = json.parse(text)
	if err != OK:
		push_error("JSON parse error in " + path + ": " + json.get_error_message())
		return {}
	
	return json.data

func get_chapter(id: String) -> Dictionary:
	return chapters.get(id, {})

func get_current_chapter() -> Dictionary:
	return current_chapter_data

func set_current_chapter(id: String):
	if chapters.has(id):
		current_chapter_data = chapters[id]
		print("Chapter set: %s — %s" % [id, current_chapter_data.get("title", "Untitled")])
	else:
		push_warning("Chapter not found: " + id)

func get_unlocked_chapters() -> Array:
	var result := []
	for id in chapters:
		var ch = chapters[id]
		if ch.get("is_unlocked", false):
			result.append(ch)
	return result