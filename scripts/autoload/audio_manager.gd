extends Node
# AudioManager — Simple pooled SFX playback
# Preloads all SFX; plays via AudioStreamPlayer pool

const SFX_DIR := "res://assets/sfx/"
const POOL_SIZE := 8

var sfx_pool: Array[AudioStreamPlayer] = []
var pool_index := 0

var sfx_cache: Dictionary = {}

@export var master_volume: float = 0.8
@export var sfx_volume: float = 0.7

func _ready():
	_create_pool()
	_load_all_sfx()
	print("AudioManager ready — %d SFX loaded" % sfx_cache.size())

func _create_pool():
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		player.volume_db = linear_to_db(sfx_volume * master_volume)
		add_child(player)
		player.finished.connect(_on_player_finished.bind(player))
		sfx_pool.append(player)

func _load_all_sfx():
	var files := [
		"sword_swing",
		"sword_hit",
		"skeleton_death",
		"player_hurt",
		"shield_block",
		"captain_charge",
		"level_complete",
		"ui_click"
	]
	for name in files:
		var path = SFX_DIR + name + ".wav"
		var stream = load(path)
		if stream:
			sfx_cache[name] = stream
		else:
			push_warning("Failed to load SFX: " + path)

func play_sfx(name: String):
	if not sfx_cache.has(name):
		push_warning("SFX not found: " + name)
		return
	
	# Find next available player
	var attempts := 0
	var start := pool_index
	while attempts < POOL_SIZE:
		var p = sfx_pool[pool_index]
		pool_index = (pool_index + 1) % POOL_SIZE
		if not p.playing:
			p.stream = sfx_cache[name]
			p.play()
			return
		attempts += 1
	
	# Fallback: stop oldest and reuse
	var oldest = sfx_pool[start]
	oldest.stop()
	oldest.stream = sfx_cache[name]
	oldest.play()

func play_random_pitch(name: String, min_pitch: float = 0.9, max_pitch: float = 1.1):
	if not sfx_cache.has(name):
		return
	
	for i in range(POOL_SIZE):
		var idx = (pool_index + i) % POOL_SIZE
		var p = sfx_pool[idx]
		if not p.playing:
			pool_index = (idx + 1) % POOL_SIZE
			p.stream = sfx_cache[name]
			p.pitch_scale = randf_range(min_pitch, max_pitch)
			p.play()
			return

func stop_all():
	for p in sfx_pool:
		p.stop()

func set_volume(vol: float):
	master_volume = clamp(vol, 0.0, 1.0)
	var db = linear_to_db(sfx_volume * master_volume)
	for p in sfx_pool:
		p.volume_db = db

func _on_player_finished(player: AudioStreamPlayer):
	player.pitch_scale = 1.0  # Reset pitch
