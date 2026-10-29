extends Node2D
## Generates the world background with grass, roads, a pond and decor
## from the unified tileset in assets/tilesets.

const TILE_SIZE := 32

# Terrain set 0 of the tileset: Grass, Road, Water
const TILESET_PATH := "res://assets/tilesets/releaf_tileset.tres"
const TERRAIN_SET := 0
const TERRAIN_ROAD := 1
const TERRAIN_WATER := 2

# Atlas coords of non-terrain tiles
const GRASS_VARIANTS := 4
const FLOWER_TILES := [Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0), Vector2i(7, 0)]
const TUFT_TILES := [Vector2i(0, 1), Vector2i(1, 1)]

var world_rect: Rect2i
var tilemap: TileMapLayer

func _init() -> void:
	world_rect = Settings.get_world_rect()

func _ready() -> void:
	generate_background()

func generate_background() -> void:
	tilemap = TileMapLayer.new()
	tilemap.tile_set = load(TILESET_PATH)
	tilemap.z_index = -10
	tilemap.position = Vector2i(world_rect.position)
	add_child(tilemap)

	var tiles_x := world_rect.size.x / TILE_SIZE
	var tiles_y := world_rect.size.y / TILE_SIZE
	for tx in range(tiles_x):
		for ty in range(tiles_y):
			tilemap.set_cell(Vector2i(tx, ty), 0, Vector2i(randi() % GRASS_VARIANTS, 0))

	tilemap.set_cells_terrain_connect(_pond_cells(tiles_x, tiles_y), TERRAIN_SET, TERRAIN_WATER)
	tilemap.set_cells_terrain_connect(_road_cells(tiles_x, tiles_y), TERRAIN_SET, TERRAIN_ROAD)
	_scatter_decor(tiles_x, tiles_y, 0.03, FLOWER_TILES)
	_scatter_decor(tiles_x, tiles_y, 0.05, TUFT_TILES)

func _pond_cells(tiles_x: int, tiles_y: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var center := Vector2(tiles_x * 4 / 5, tiles_y / 5)
	var radius := Vector2(7, 4)
	for tx in range(tiles_x):
		for ty in range(tiles_y):
			var d := (Vector2(tx, ty) - center) / radius
			if d.length_squared() <= 1.0:
				cells.append(Vector2i(tx, ty))
	return cells

func _road_cells(tiles_x: int, tiles_y: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []

	# Main horizontal road (2 tiles wide)
	var road_y := tiles_y / 2
	for tx in range(tiles_x):
		cells.append(Vector2i(tx, road_y))
		cells.append(Vector2i(tx, road_y + 1))

	# Main vertical road (2 tiles wide)
	var road_x := tiles_x / 3
	for ty in range(tiles_y):
		cells.append(Vector2i(road_x, ty))
		cells.append(Vector2i(road_x + 1, ty))

	# Winding path
	var path_x := tiles_x * 2 / 3
	for ty in range(tiles_y):
		var prev_x := path_x
		path_x += randi() % 3 - 1
		path_x = clamp(path_x, 2, tiles_x - 3)
		# Fill the span between old and new x so rows touch by side, not only diagonally
		for x in range(mini(prev_x, path_x), maxi(prev_x, path_x) + 1):
			cells.append(Vector2i(x, ty))
	return cells

## Places decor only on plain grass cells so it never overwrites road or water.
func _scatter_decor(tiles_x: int, tiles_y: int, chance: float, atlas_coords: Array) -> void:
	for tx in range(tiles_x):
		for ty in range(tiles_y):
			var cell := Vector2i(tx, ty)
			var current := tilemap.get_cell_atlas_coords(cell)
			if current.y == 0 and current.x < GRASS_VARIANTS and randf() < chance:
				tilemap.set_cell(cell, 0, atlas_coords[randi() % atlas_coords.size()])
