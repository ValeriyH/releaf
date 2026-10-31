#!/usr/bin/env python3
"""Generates the Releaf terrain tileset (Godot 4.x) in the unified 32-colour palette.

Usage:  python generate_tileset.py        (requires: pip install pillow)

Everything is written to ./output next to this script; nothing outside this folder is
touched. Outputs:
  releaf_tileset.png   32x32 tiles, 8 columns: grass/flowers/tufts, road blob-47, water blob-47
  releaf_tileset.tres  Godot TileSet with terrain set 0 (match corners and sides) wired up
  palette.gpl          GIMP/Aseprite/Krita palette
  palette.png          swatch sheet
  preview.png          demo map built with the same autotile rules (3x nearest-neighbour)

Light comes from the top-left; terrain edges get a dark outline, a light rim on the
top/left side and a dark rim on the bottom/right side. The outline colour is never pure black.
"""
from pathlib import Path

from PIL import Image

TILE = 32
COLS = 8
HERE = Path(__file__).resolve().parent
OUT = HERE / "output"
RES_DIR = "res://assets/tilesets"

# --- Palette (32 colours). Anchors come from the existing terrain atlas / player sprite. ---
PALETTE = {
	# greens: dark shadow -> light highlight
	"g0": "#004337", "g1": "#006B46", "g2": "#2F8136", "g3": "#499231", "g4": "#64A42C", "g5": "#8CBF3F",
	# dirt / wood
	"d0": "#342116", "d1": "#5E351D", "d2": "#7D4D35", "d3": "#9B673A", "d4": "#B98650", "d5": "#C39753", "d6": "#DDB872",
	# stone
	"s0": "#322125", "s1": "#4A444E", "s2": "#5D5253", "s3": "#806F66", "s4": "#A89A8F",
	# water
	"w0": "#0B3B5E", "w1": "#156C99", "w2": "#2A8FBF", "w3": "#6CBBDB", "w4": "#CDEBF2",
	# character / fire / warm accents (player outline + fox)
	"o1": "#322C43", "f1": "#B5422D", "f2": "#E87838", "f3": "#F0B989", "f4": "#A36F4E", "wh": "#FFFFFF",
	# flowers
	"y1": "#D9A441", "p1": "#D95F6B", "v1": "#7A5FA8",
}
assert len(PALETTE) == 32


def rgb(key):
	h = PALETTE[key].lstrip("#")
	return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255)


# --- Deterministic tileable noise (depends only on tile-local coordinates) ---
def noise(x, y, seed):
	n = ((x % TILE) * 374761393 + (y % TILE) * 668265263 + seed * 2246822519) & 0xFFFFFFFF
	n = ((n ^ (n >> 13)) * 1274126177) & 0xFFFFFFFF
	return ((n ^ (n >> 16)) & 0xFFFF) / 65535.0


def grass_px(x, y, seed=0):
	r = noise(x, y, seed)
	if r < 0.08:
		return "g1"
	if r > 0.975:
		return "g4"
	if r > 0.90:
		return "g3"
	return "g2"


def dirt_px(x, y, seed=0):
	r = noise(x, y, seed + 31)
	if r < 0.02:
		return "d2"
	if r < 0.12:
		return "d3"
	if r > 0.93:
		return "d5"
	return "d4"


def water_px(x, y, seed=0):
	# Wave dashes: period 8 in y and 16 in x, so the pattern tiles at 32px.
	if y % 8 == 3 and (x + (y // 8) * 5) % 16 < 4:
		return "w2"
	if noise(x, y, seed + 57) > 0.985:
		return "w3"
	return "w1"


# --- Blob-47 autotile geometry ---
N, NE, E, SE, S, SW, W, NW = 1, 2, 4, 8, 16, 32, 64, 128
INSET = 4      # how far an exposed edge is pulled in from the tile border
CHAMFER = 3    # rounding of convex corners

# peering bit name for each neighbour flag
PEERING = {
	N: "top_side", NE: "top_right_corner", E: "right_side", SE: "bottom_right_corner",
	S: "bottom_side", SW: "bottom_left_corner", W: "left_side", NW: "top_left_corner",
}


def canonical(mask):
	"""Drops corner flags whose two adjacent sides are not both set (47 unique masks remain)."""
	for corner, (a, b) in {NE: (N, E), SE: (S, E), SW: (S, W), NW: (N, W)}.items():
		if mask & corner and not (mask & a and mask & b):
			mask &= ~corner
	return mask


BLOB = sorted({canonical(m) for m in range(256)})
assert len(BLOB) == 47


def shape(mask):
	"""32x32 boolean grid: True where the tile shows the terrain, False where it shows grass."""
	grid = [[False] * TILE for _ in range(TILE)]
	for y in range(TILE):
		for x in range(TILE):
			right, bottom = x >= TILE // 2, y >= TILE // 2
			dx = TILE - 1 - x if right else x
			dy = TILE - 1 - y if bottom else y
			v_side = S if bottom else N
			h_side = E if right else W
			corner = {(False, False): NW, (True, False): NE, (False, True): SW, (True, True): SE}[(right, bottom)]
			v, h = bool(mask & v_side), bool(mask & h_side)
			if v and h:
				if mask & corner:
					inside = True
				else:  # concave notch in the tile corner
					inside = not (dx < INSET and dy < INSET and dx + dy < 2 * INSET - 2)
			elif v:
				inside = dx >= INSET
			elif h:
				inside = dy >= INSET
			else:
				a, b = dx - INSET, dy - INSET
				inside = a >= 0 and b >= 0 and a + b >= CHAMFER - 1
			grid[y][x] = inside
	return grid


def blob_tile(mask, fill, outline, light, dark):
	grid = shape(mask)

	def inside(x, y):
		return grid[y][x] if 0 <= x < TILE and 0 <= y < TILE else True

	def is_outline(x, y):
		return inside(x, y) and not (inside(x - 1, y) and inside(x + 1, y) and inside(x, y - 1) and inside(x, y + 1))

	img = Image.new("RGBA", (TILE, TILE))
	for y in range(TILE):
		for x in range(TILE):
			if not grid[y][x]:
				key = grass_px(x, y)
			elif is_outline(x, y):
				key = outline
			elif is_outline(x, y - 1) or is_outline(x - 1, y):
				key = light  # rim on the side facing the light (top-left)
			elif is_outline(x, y + 1) or is_outline(x + 1, y):
				key = dark
			else:
				key = fill(x, y)
			img.putpixel((x, y), rgb(key))
	return img


def road_tile(mask):
	return blob_tile(mask, dirt_px, outline="d1", light="d6", dark="d3")


def water_tile(mask):
	return blob_tile(mask, water_px, outline="w0", light="w3", dark="w0")


# --- Decor tiles (grass + sprite) ---
def grass_tile(seed):
	img = Image.new("RGBA", (TILE, TILE))
	for y in range(TILE):
		for x in range(TILE):
			img.putpixel((x, y), rgb(grass_px(x, y, seed)))
	return img


def flower_tile(seed, petal, center, cx, cy):
	img = grass_tile(seed)
	for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)):
		img.putpixel((cx + dx, cy + dy), rgb(petal))
	img.putpixel((cx, cy), rgb(center))
	img.putpixel((cx, cy + 2), rgb("g1"))
	img.putpixel((cx, cy + 3), rgb("g1"))
	return img


def tuft_tile(seed, blades):
	img = grass_tile(seed)
	for bx, by, h in blades:
		for i in range(h):
			img.putpixel((bx + (i // 3), by - i), rgb("g4"))
		img.putpixel((bx, by + 1), rgb("g0"))
		img.putpixel((bx + 1, by + 1), rgb("g0"))
	return img


def build_tiles():
	"""Returns (ordered list of (name, image, kind)), kind in grass|decor|road|water."""
	tiles = []
	for i in range(4):
		tiles.append((f"grass_{i}", grass_tile(i), "grass"))
	flowers = [("y1", "f2", 9, 10), ("p1", "f3", 21, 8), ("v1", "f3", 12, 22), ("wh", "y1", 23, 21)]
	for i, (petal, center, cx, cy) in enumerate(flowers):
		tiles.append((f"flower_{i}", flower_tile(i, petal, center, cx, cy), "decor"))
	tiles.append(("tuft_0", tuft_tile(0, [(8, 20, 6), (12, 22, 5), (16, 21, 7), (20, 22, 5)]), "decor"))
	tiles.append(("tuft_1", tuft_tile(1, [(10, 12, 5), (14, 13, 7), (19, 12, 6), (23, 14, 4)]), "decor"))
	while len(tiles) < 16:  # pad base block to two full rows
		tiles.append((None, None, None))
	for m in BLOB:
		tiles.append((f"road_{m}", road_tile(m), "road"))
	tiles.append((None, None, None))  # 47 -> 48 slots (6 rows x 8)
	for m in BLOB:
		tiles.append((f"water_{m}", water_tile(m), "water"))
	tiles.append((None, None, None))
	return tiles


def pos(index):
	return index % COLS, index // COLS


# --- Terrain ids: 0 Grass, 1 Road, 2 Water ---
TERRAINS = [("Grass", (0.18, 0.51, 0.21)), ("Road", (0.73, 0.53, 0.31)), ("Water", (0.08, 0.42, 0.60))]
ROAD_BASE, WATER_BASE = 16, 64


def write_tres(path):
	lines = [
		'[gd_resource type="TileSet" load_steps=3 format=3]',
		"",
		f'[ext_resource type="Texture2D" path="{RES_DIR}/releaf_tileset.png" id="1_tex"]',
		"",
		'[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_main"]',
		'texture = ExtResource("1_tex")',
		"texture_region_size = Vector2i(32, 32)",
	]

	def add(index, terrain, mask):
		col, row = pos(index)
		lines.append(f"{col}:{row}/0 = 0")
		if terrain is None:
			return
		lines.append(f"{col}:{row}/0/terrain_set = 0")
		lines.append(f"{col}:{row}/0/terrain = {terrain}")
		for flag, name in PEERING.items():
			lines.append(f"{col}:{row}/0/terrains_peering_bit/{name} = {terrain if mask & flag else 0}")

	for i in range(4):
		add(i, 0, 0)               # grass variants: terrain Grass, all neighbours Grass
	for i in range(4, 10):
		add(i, None, 0)            # flowers/tufts: manual placement only, not part of terrain
	for n, m in enumerate(BLOB):
		add(ROAD_BASE + n, 1, m)
	for n, m in enumerate(BLOB):
		add(WATER_BASE + n, 2, m)

	lines += ["", "[resource]", "tile_size = Vector2i(32, 32)", "terrain_set_0/mode = 0"]
	for i, (name, (r, g, b)) in enumerate(TERRAINS):
		lines.append(f'terrain_set_0/terrain_{i}/name = "{name}"')
		lines.append(f"terrain_set_0/terrain_{i}/color = Color({r}, {g}, {b}, 1)")
	lines.append('sources/0 = SubResource("TileSetAtlasSource_main")')
	path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_palette(out):
	gpl = ["GIMP Palette", "Name: Releaf32", "Columns: 8", "#"]
	for key, hexv in PALETTE.items():
		r, g, b, _ = rgb(key)
		gpl.append(f"{r:3d} {g:3d} {b:3d} {key} {hexv}")
	(out / "palette.gpl").write_text("\n".join(gpl) + "\n", encoding="utf-8")
	sw = Image.new("RGBA", (8 * 16, 4 * 16))
	for i, key in enumerate(PALETTE):
		sw.paste(Image.new("RGBA", (16, 16), rgb(key)), ((i % 8) * 16, (i // 8) * 16))
	sw.save(out / "palette.png")


def build_preview(atlas):
	layout = [
		"gggggggggggggggggggggggg",
		"gggggggggrgggggggggggggg",
		"gggggggggrgggggwwwwgggg",
		"ggggggggrrrrrrrwwwwwwggg",
		"gggggggggrgggggwwwwwwggg",
		"gggggggggrggggggwwwwgggg",
		"rrrrrrrrrrrrrrrgggggggggg",
		"rrrrrrrrrrrrrrrgggggggggg",
		"gggggggggrgggggggggggggg",
		"gggggggggrgggggggggggggg",
		"gggggggggrgggggggggggggg",
	]
	w = max(len(r) for r in layout)
	grid = [r.ljust(w, "g") for r in layout]
	h = len(grid)
	img = Image.new("RGBA", (w * TILE, h * TILE))

	def at(x, y, kind):
		return grid[min(max(y, 0), h - 1)][min(max(x, 0), w - 1)] == kind

	for y in range(h):
		for x in range(w):
			kind = grid[y][x]
			if kind == "g":
				idx = (x * 7 + y * 13) % 4
			else:
				mask = 0
				for flag, (dx, dy) in {N: (0, -1), NE: (1, -1), E: (1, 0), SE: (1, 1),
									   S: (0, 1), SW: (-1, 1), W: (-1, 0), NW: (-1, -1)}.items():
					if at(x + dx, y + dy, kind):
						mask |= flag
				idx = (ROAD_BASE if kind == "r" else WATER_BASE) + BLOB.index(canonical(mask))
			col, row = pos(idx)
			tile = atlas.crop((col * TILE, row * TILE, (col + 1) * TILE, (row + 1) * TILE))
			img.paste(tile, (x * TILE, y * TILE))
	return img.resize((img.width * 3, img.height * 3), Image.NEAREST)


def main():
	OUT.mkdir(exist_ok=True)
	tiles = build_tiles()
	rows = (len(tiles) + COLS - 1) // COLS
	atlas = Image.new("RGBA", (COLS * TILE, rows * TILE), (0, 0, 0, 0))
	for i, (_, img, _) in enumerate(tiles):
		if img is not None:
			col, row = pos(i)
			atlas.paste(img, (col * TILE, row * TILE))

	allowed = {rgb(k) for k in PALETTE} | {(0, 0, 0, 0)}
	used = {color for _, color in atlas.getcolors(maxcolors=TILE * TILE * COLS * rows)}
	stray = used - allowed
	if stray:
		raise SystemExit(f"Colours outside the palette: {sorted(stray)[:5]}")

	atlas.save(OUT / "releaf_tileset.png")
	write_tres(OUT / "releaf_tileset.tres")
	write_palette(OUT)
	build_preview(atlas).save(OUT / "preview.png")
	print(f"OK: {atlas.size[0]}x{atlas.size[1]} atlas, {len(used - {(0, 0, 0, 0)})} colours used, output in {OUT}")


if __name__ == "__main__":
	main()
