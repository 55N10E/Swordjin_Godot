extends Node2D
## ArenaBuilder — Procedural tilemap arena generator for Swordjin chapters.
## Reads chapter_id from ChapterDatabase and builds a themed arena with walls,
## ground, decorations, and optional hazards.
##
## Tile types: 0=void, 1=ground, 2=wall, 3=wall_top, 4=decoration, 5=path, 6=hazard

const TILE_SIZE := 16
const ARENA_W := 40   # 40 tiles × 16px = 640px
const ARENA_H := 22   # 22 tiles × 16px = 352px (leaves 8px for UI at bottom)

# Theme mapping from chapter_id to tileset
const CHAPTER_THEMES := {
	"act01_ch001": "field",
	"act01_ch002": "forest",
	"act01_ch003": "fortress",
	"act01_ch004": "dark_fortress",
}

# Arena layout templates (procedural patterns per theme)
# 0=void, 1=ground, 2=wall, 3=wall_top, 4=decoration, 5=path, 6=hazard
# Each layout is ARENA_H rows × ARENA_W cols

var tilemap: TileMap
var current_theme: String = "field"


func _init():
	# Create TileMap node
	tilemap = TileMap.new()
	tilemap.name = "ArenaTileMap"
	tilemap.z_index = -10  # Behind everything
	tilemap.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST  # Pixel-perfect


func setup(chapter_id: String, parent: Node2D) -> void:
	current_theme = CHAPTER_THEMES.get(chapter_id, "field")
	
	# Load tileset
	var tileset_path = "res://assets/tileset_%s.png" % current_theme
	var tex = load(tileset_path)
	if not tex:
		push_warning("ArenaBuilder: tileset not found at %s, using flat ground" % tileset_path)
		_add_flat_ground(parent)
		return
	
	# Build Godot TileSet resource
	var tileset = _build_tileset(tex)
	tilemap.tile_set = tileset
	
	# Generate layout
	var layout = _generate_layout(current_theme, chapter_id)
	
	# Paint tiles
	_paint_layout(layout)
	
	# Add collision for wall tiles
	_add_wall_collision(layout, parent)
	
	parent.add_child(tilemap)
	parent.move_child(tilemap, 0)  # Behind everything


func _build_tileset(tex: Texture2D) -> TileSet:
	var ts = TileSet.new()
	ts.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	
	# Add physics layer for wall collisions
	ts.add_physics_layer(0)
	ts.set_physics_layer_collision_mask(0, 1)  # Collide with layer 1
	
	# Create one source for all tiles (horizontal strip)
	var source = TileSetAtlasSource.new()
	source.texture = tex
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	source.margins = Vector2i(0, 0)
	source.separation = Vector2i(0, 0)
	
	# 7 tiles in a row (0-6)
	source.columns = 7
	source.rows = 1
	
	# Define collision for wall tiles (tile types 2 and 3)
	var wall_poly = [
		Vector2(0, 0), Vector2(TILE_SIZE, 0),
		Vector2(TILE_SIZE, TILE_SIZE), Vector2(0, TILE_SIZE)
	]
	for i in [2, 3]:  # wall + wall_top
		var coords = Vector2i(i, 0)
		source.add_collision_polygon(coords, 0, wall_poly)
	
	# Hazard tiles (6) — also solid, blocks movement
	var hazard_coords = Vector2i(6, 0)
	source.add_collision_polygon(hazard_coords, 0, wall_poly)
	
	ts.add_source(source, 0)
	return ts


func _generate_layout(theme: String, chapter_id: String) -> Array:
	var layout = []
	
	# Start with all ground
	for y in range(ARENA_H):
		var row = []
		for x in range(ARENA_W):
			row.append(1)  # ground
		layout.append(row)
	
	# Border walls (2 tiles thick for visual depth)
	for y in range(ARENA_H):
		for x in range(ARENA_W):
			if x < 2 or x >= ARENA_W - 2 or y < 2 or y >= ARENA_H - 2:
				if y < 2 or y >= ARENA_H - 2:
					layout[y][x] = 2  # wall
				elif x < 2 or x >= ARENA_W - 2:
					layout[y][x] = 2  # wall
			# Inner wall edge (wall_top for visual transition)
			elif x == 2 or x == ARENA_W - 3 or y == 2 or y == ARENA_H - 3:
				if theme in ["fortress", "dark_fortress"]:
					layout[y][x] = 3  # wall_top (stone edge)
	
	# Theme-specific features
	match theme:
		"field":
			_layout_field(layout, chapter_id)
		"forest":
			_layout_forest(layout, chapter_id)
		"fortress":
			_layout_fortress(layout, chapter_id)
		"dark_fortress":
			_layout_dark_fortress(layout, chapter_id)
	
	return layout


func _layout_field(layout: Array, _chapter_id: String) -> void:
	# Scattered grass tufts and a dirt path
	# Path down the middle
	for y in range(10, 13):
		for x in range(3, ARENA_W - 3):
			if layout[y][x] == 1:
				layout[y][x] = 5  # path
	
	# Grass tufts (decoration)
	var tufts = [
		[4, 5], [6, 14], [8, 22], [5, 30], [7, 8],
		[15, 6], [17, 18], [14, 28], [16, 35], [18, 12],
		[12, 20], [11, 33], [19, 25], [13, 9], [9, 36],
	]
	for t in tufts:
		if t[1] < ARENA_W - 3 and t[0] < ARENA_H - 3:
			layout[t[0]][t[1]] = 4
	
	# Small pond (water)
	for y in range(16, 19):
		for x in range(30, 34):
			if y < ARENA_H - 3 and x < ARENA_W - 3:
				layout[y][x] = 6


func _layout_forest(layout: Array, _chapter_id: String) -> void:
	# Dense tree walls forming corridors
	# Tree clusters (wall blocks)
	var tree_clusters = [
		[4, 5, 3, 3], [4, 32, 4, 2], [10, 8, 2, 4], [14, 25, 3, 3],
		[6, 18, 2, 2], [16, 12, 2, 2], [12, 34, 3, 2],
	]
	for cluster in tree_clusters:
		var cy = cluster[0]
		var cx = cluster[1]
		var ch = cluster[2]
		var cw = cluster[3]
		for y in range(cy, cy + ch):
			for x in range(cx, cx + cw):
				if y < ARENA_H - 3 and x < ARENA_W - 3 and y > 2 and x > 2:
					layout[y][x] = 2
	
	# Bushes (decoration)
	var bushes = [
		[5, 10], [7, 15], [9, 20], [11, 5], [13, 30],
		[15, 8], [17, 22], [8, 28], [6, 35], [19, 15],
	]
	for b in bushes:
		if b[1] < ARENA_W - 3 and b[0] < ARENA_H - 3:
			layout[b[0]][b[1]] = 4
	
	# Forest path
	for y in range(8, 14):
		for x in range(3, 7):
			if layout[y][x] == 1:
				layout[y][x] = 5


func _layout_fortress(layout: Array, chapter_id: String) -> void:
	# Stone walls forming rooms/corridors
	# Interior walls creating an L-shaped corridor
	# Top wall segment
	for x in range(8, 25):
		layout[6][x] = 2
		layout[7][x] = 3  # wall_top edge
	# Right wall segment
	for y in range(7, 16):
		layout[y][24] = 2
		layout[y][25] = 3  # wall_top edge
	
	# Pillar clusters
	var pillars = [[5, 30], [5, 33], [10, 30], [10, 33], [15, 30], [15, 33]]
	for p in pillars:
		if p[1] < ARENA_W - 3 and p[0] < ARENA_H - 3:
			layout[p[0]][p[1]] = 2
			layout[p[0]][p[1] + 1] = 2
			layout[p[0] + 1][p[1]] = 2
			layout[p[0] + 1][p[1] + 1] = 2
	
	# Blood/cracks (decoration)
	var cracks = [[8, 12], [12, 18], [16, 8], [9, 28], [14, 35]]
	for c in cracks:
		if c[1] < ARENA_W - 3 and c[0] < ARENA_H - 3:
			layout[c[0]][c[1]] = 4
	
	# Worn stone path
	for y in range(3, 6):
		for x in range(12, 18):
			if layout[y][x] == 1:
				layout[y][x] = 5


func _layout_dark_fortress(layout: Array, chapter_id: String) -> void:
	# Same base as fortress but with lava channels and darker feel
	# Reuse fortress layout first
	_layout_fortress(layout, chapter_id)
	
	# Add lava channels along bottom
	for x in range(6, 20):
		layout[ARENA_H - 4][x] = 6  # lava
		layout[ARENA_H - 5][x] = 6
	
	# Lava pool top-right
	for y in range(3, 6):
		for x in range(32, 37):
			if y < ARENA_H - 3 and x < ARENA_W - 3:
				layout[y][x] = 6
	
	# Extra wall for gate area
	for y in range(5, 10):
		layout[y][ARENA_W - 4] = 2
		layout[y][ARENA_W - 5] = 3


func _paint_layout(layout: Array) -> void:
	tilemap.clear()
	for y in range(layout.size()):
		for x in range(layout[y].size()):
			var tile_type = layout[y][x]
			if tile_type > 0:  # Skip void (0)
				tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(tile_type, 0))


func _add_wall_collision(layout: Array, parent: Node2D) -> void:
	# TileMap collision is handled by the TileSet collision polygons
	# But we also add StaticBody2D walls at the arena boundary for safety
	# (the existing walls in main.tscn)
	# Remove old ColorRect — tilemap handles visuals now
	var color_rect = parent.get_node_or_null("ColorRect")
	if color_rect:
		color_rect.queue_free()


func _add_flat_ground(parent: Node2D) -> void:
	# Fallback: no tileset, just ground color
	var color_rect = ColorRect.new()
	color_rect.name = "GroundFallback"
	color_rect.z_index = -10
	var chapter_data = ChapterDatabase.get_current_chapter()
	var bg = chapter_data.get("background_color", [0.08, 0.1, 0.12])
	color_rect.color = Color(bg[0], bg[1], bg[2])
	color_rect.size = Vector2(640, 360)
	parent.add_child(color_rect)
	parent.move_child(color_rect, 0)


# Return array of Vector2 positions that are on ground/path tiles.
# Used for enemy spawn validation.
func get_walkable_positions() -> Array:
	var positions = []
	for y in range(ARENA_H):
		for x in range(ARENA_W):
			if tilemap.get_cell_source_id(0, Vector2i(x, y)) != -1:
				var atlas = tilemap.get_cell_atlas_coords(0, Vector2i(x, y))
				var tile_type = atlas.x
				if tile_type in [1, 5]:  # ground or path
					positions.append(Vector2(x * TILE_SIZE + TILE_SIZE / 2, y * TILE_SIZE + TILE_SIZE / 2))
	return positions