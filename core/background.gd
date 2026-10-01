extends Node2D
## Procedurally generates the world background with grass, roads, and flowers.

const TILE_SIZE := 32

var world_rect: Rect2i

func _init() -> void:
	world_rect = Settings.get_world_rect()

# Atlas tile indices
const GRASS_0 := 0
const GRASS_1 := 1
const GRASS_2 := 2
const GRASS_3 := 3
const ROAD := 4
const ROAD_EDGE := 5
const FLOWER_0 := 6
const FLOWER_1 := 7
const FLOWER_2 := 8
const FLOWER_3 := 9
const TUFT_0 := 10
const TUFT_1 := 11

const GRASS_TILES := [GRASS_0, GRASS_1, GRASS_2, GRASS_3]
const FLOWER_TILES := [FLOWER_0, FLOWER_1, FLOWER_2, FLOWER_3]
const TUFT_TILES := [TUFT_0, TUFT_1]

# Colors
const GRASS_COLORS := [
	Color(0.24, 0.42, 0.20),
	Color(0.26, 0.44, 0.22),
	Color(0.22, 0.40, 0.18),
	Color(0.25, 0.43, 0.21),
]
const ROAD_COLOR := Color(0.45, 0.38, 0.30)
const ROAD_EDGE_COLOR := Color(0.38, 0.32, 0.24)
const FLOWER_COLORS := [
	Color(0.9, 0.3, 0.4),
	Color(0.9, 0.8, 0.2),
	Color(0.7, 0.4, 0.8),
	Color(0.9, 0.5, 0.2),
]
const TUFT_COLOR := Color(0.18, 0.35, 0.15)

var tilemap: TileMapLayer

func _ready() -> void:
	generate_background()

func generate_background() -> void:
	tilemap = TileMapLayer.new()
	tilemap.tile_set = _create_tileset()
	tilemap.z_index = -10
	tilemap.position = Vector2i(world_rect.position)
	add_child(tilemap)

	_fill_grass()
	_add_roads()
	_add_flowers()
	_add_tufts()

func _create_tileset() -> TileSet:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)

	var atlas := _create_atlas_texture()
	var source := TileSetAtlasSource.new()
	source.texture = atlas
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)

	for i in range(12):
		source.create_tile(Vector2i(i, 0))

	tileset.add_source(source, 0)
	return tileset

func _create_atlas_texture() -> ImageTexture:
	var width := 12 * TILE_SIZE
	var height := TILE_SIZE
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)

	for i in range(4):
		_draw_grass(image, i * TILE_SIZE, 0, i)

	_draw_road(image, 4 * TILE_SIZE, 0)
	_draw_road_edge(image, 5 * TILE_SIZE, 0)

	for i in range(4):
		_draw_flower(image, (6 + i) * TILE_SIZE, 0, i)

	_draw_tuft(image, 10 * TILE_SIZE, 0, 0)
	_draw_tuft(image, 11 * TILE_SIZE, 0, 1)

	return ImageTexture.create_from_image(image)

func _draw_grass(image: Image, ox: int, oy: int, variant: int) -> void:
	var base: Color = GRASS_COLORS[variant]
	for x in range(TILE_SIZE):
		for y in range(TILE_SIZE):
			var n := randf_range(-0.02, 0.02)
			image.set_pixel(ox + x, oy + y, base + Color(n, n, n, 0))

func _draw_road(image: Image, ox: int, oy: int) -> void:
	for x in range(TILE_SIZE):
		for y in range(TILE_SIZE):
			var n := randf_range(-0.02, 0.02)
			image.set_pixel(ox + x, oy + y, ROAD_COLOR + Color(n, n, n, 0))

func _draw_road_edge(image: Image, ox: int, oy: int) -> void:
	for x in range(TILE_SIZE):
		for y in range(TILE_SIZE):
			var n := randf_range(-0.02, 0.02)
			image.set_pixel(ox + x, oy + y, ROAD_EDGE_COLOR + Color(n, n, n, 0))

func _draw_flower(image: Image, ox: int, oy: int, variant: int) -> void:
	_draw_grass(image, ox, oy, variant % 4)
	var color: Color = FLOWER_COLORS[variant]
	var cx := ox + TILE_SIZE / 2
	var cy := oy + TILE_SIZE / 2
	for angle in range(0, 360, 45):
		var rad := deg_to_rad(angle)
		_draw_circle(image, cx + int(cos(rad) * 5), cy + int(sin(rad) * 5), 3, color)
	_draw_circle(image, cx, cy, 3, Color(1, 0.9, 0.2))

func _draw_tuft(image: Image, ox: int, oy: int, variant: int) -> void:
	_draw_grass(image, ox, oy, variant % 4)
	var cx := ox + TILE_SIZE / 2
	var cy := oy + TILE_SIZE / 2
	for i in range(-2, 3):
		var bx := cx + i * 3
		var by := cy + 4
		for j in range(6):
			image.set_pixel(bx + (j % 2), by - j, TUFT_COLOR)

func _draw_circle(image: Image, cx: int, cy: int, r: int, color: Color) -> void:
	for x in range(cx - r, cx + r + 1):
		for y in range(cy - r, cy + r + 1):
			if (x - cx) * (x - cx) + (y - cy) * (y - cy) <= r * r:
				if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
					image.set_pixel(x, y, color)

func _fill_grass() -> void:
	var tiles_x := world_rect.size.x / TILE_SIZE
	var tiles_y := world_rect.size.y / TILE_SIZE
	for tx in range(tiles_x):
		for ty in range(tiles_y):
			tilemap.set_cell(Vector2i(tx, ty), 0, Vector2i(GRASS_TILES[randi() % 4], 0))

func _add_roads() -> void:
	var tiles_x := world_rect.size.x / TILE_SIZE
	var tiles_y := world_rect.size.y / TILE_SIZE

	# Main horizontal road (2 tiles wide)
	var road_y := tiles_y / 2
	for tx in range(tiles_x):
		tilemap.set_cell(Vector2i(tx, road_y), 0, Vector2i(ROAD, 0))
		tilemap.set_cell(Vector2i(tx, road_y + 1), 0, Vector2i(ROAD, 0))

	# Main vertical road (2 tiles wide)
	var road_x := tiles_x / 3
	for ty in range(tiles_y):
		tilemap.set_cell(Vector2i(road_x, ty), 0, Vector2i(ROAD, 0))
		tilemap.set_cell(Vector2i(road_x + 1, ty), 0, Vector2i(ROAD, 0))

	# Winding path
	var path_x := tiles_x * 2 / 3
	for ty in range(tiles_y):
		path_x += randi() % 3 - 1
		path_x = clamp(path_x, 2, tiles_x - 3)
		tilemap.set_cell(Vector2i(path_x, ty), 0, Vector2i(ROAD, 0))

func _add_flowers() -> void:
	var tiles_x := world_rect.size.x / TILE_SIZE
	var tiles_y := world_rect.size.y / TILE_SIZE
	for tx in range(tiles_x):
		for ty in range(tiles_y):
			if randf() < 0.03:
				tilemap.set_cell(Vector2i(tx, ty), 0, Vector2i(FLOWER_TILES[randi() % 4], 0))

func _add_tufts() -> void:
	var tiles_x := world_rect.size.x / TILE_SIZE
	var tiles_y := world_rect.size.y / TILE_SIZE
	for tx in range(tiles_x):
		for ty in range(tiles_y):
			if randf() < 0.05:
				tilemap.set_cell(Vector2i(tx, ty), 0, Vector2i(TUFT_TILES[randi() % 2], 0))
