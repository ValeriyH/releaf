#!/usr/bin/env python3
"""Draws the application icon with the Releaf32 palette: a leaf growing out of a fire.

Usage:  python generate_icon.py        (requires: pip install pillow)
Output: output/icon/icon.png (256x256, 4x nearest) and output/icon/preview.png (common sizes).
"""
import math
from pathlib import Path

from PIL import Image

from generate_tileset import rgb

HERE = Path(__file__).resolve().parent
OUT = HERE / "output" / "icon"

SIZE = 64
CORNER = 12
SCALE = 4

LEAF_BASE = (13.0, 49.0)
LEAF_TIP = (54.0, 7.0)
LEAF_RADIUS = 44.0  # Bigger is slimmer
CHAR_LINE = 45.0  # Below this row the leaf is burned


def in_rounded_square(x, y):
	cx = min(x, SIZE - 1 - x)
	cy = min(y, SIZE - 1 - y)
	if cx >= CORNER or cy >= CORNER:
		return True
	return math.hypot(CORNER - 0.5 - cx, CORNER - 0.5 - cy) <= CORNER


def flame_height(x, spread):
	"""Height of the flame tongues above the bottom edge at column x."""
	t = x / (SIZE - 1)
	envelope = math.sin(math.pi * t) ** 0.6
	tongues = 0.68 + 0.32 * math.sin(x * 0.42 + 0.7)
	return spread * envelope * tongues


def background(x, y):
	# Night sky, lighter towards the top left where the light comes from
	if x + y < 42:
		key = "g1"
	else:
		key = "g0"
	# Fire on the ground, from the outside in
	up = SIZE - 1 - y
	if up < flame_height(x, 15):
		return "y1"
	if up < flame_height(x, 24):
		return "f2"
	if up < flame_height(x, 33):
		return "f1"
	return key


def leaf_side(x, y):
	"""Signed distance from the midrib, or None outside the leaf. Negative is the top-left half."""
	ax, ay = LEAF_BASE
	bx, by = LEAF_TIP
	dx, dy = bx - ax, by - ay
	length = math.hypot(dx, dy)
	offset = math.sqrt(LEAF_RADIUS ** 2 - (length / 2) ** 2)
	mx, my = (ax + bx) / 2, (ay + by) / 2
	nx, ny = -dy / length, dx / length
	for sign in (1, -1):
		if math.hypot(x - (mx + nx * offset * sign), y - (my + ny * offset * sign)) > LEAF_RADIUS:
			return None
	return ((x - ax) * nx + (y - ay) * ny) * -1


def stem(x, y):
	ax, ay = LEAF_BASE
	along = (x - ax) * -0.7 + (y - ay) * 0.7
	across = (x - ax) * 0.7 + (y - ay) * 0.7
	return 0 <= along <= 9 and abs(across) < 1.3


def leaf_pixel(x, y):
	side = leaf_side(x, y)
	if side is None:
		return "d1" if stem(x, y) else None
	wave = CHAR_LINE + 1.5 * math.sin(x * 0.9)
	if y > wave + 1.5:
		return "s0"
	if y > wave:
		return "f3"
	if abs(side) < 0.8:
		return "g1"
	# Side veins, slanted towards the tip
	ax, ay = LEAF_BASE
	along = (x - ax) * 0.698 + (y - ay) * -0.715
	if (along - abs(side) * 0.9) % 9 < 1:
		return "g2" if side > 0 else "g3"
	if side < -6:
		return "g5"
	if side < 0:
		return "g4"
	return "g3"


def main():
	img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
	leaf = {}
	for y in range(SIZE):
		for x in range(SIZE):
			key = leaf_pixel(x, y)
			if key:
				leaf[(x, y)] = key
	for y in range(SIZE):
		for x in range(SIZE):
			if not in_rounded_square(x, y):
				continue
			key = leaf.get((x, y))
			if key is None:
				near_leaf = any((x + dx, y + dy) in leaf for dx in (-1, 0, 1) for dy in (-1, 0, 1))
				key = "d0" if near_leaf else background(x, y)
			img.putpixel((x, y), rgb(key))

	OUT.mkdir(parents=True, exist_ok=True)
	icon = img.resize((SIZE * SCALE, SIZE * SCALE), Image.NEAREST)
	icon.save(OUT / "icon.png")

	# What it looks like at launcher, taskbar and tab sizes, on light and dark
	sizes = (128, 64, 48, 32, 16)
	preview = Image.new("RGBA", (sum(sizes) + 12 * (len(sizes) + 1), 300), rgb("wh"))
	preview.paste(rgb("o1"), (0, 150, preview.width, 300))
	x = 12
	for s in sizes:
		small = icon.resize((s, s), Image.LANCZOS if s < SIZE else Image.NEAREST)
		preview.alpha_composite(small, (x, 11))
		preview.alpha_composite(small, (x, 161))
		x += s + 12
	preview.save(OUT / "preview.png")
	print("OK:", OUT)


if __name__ == "__main__":
	main()
