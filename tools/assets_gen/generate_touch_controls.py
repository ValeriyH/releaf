#!/usr/bin/env python3
"""Draws the touch controls (joystick, action button, item slots) with the Releaf32 palette.

Usage:  python generate_touch_controls.py        (requires: pip install pillow)
Output: output/touch_controls/*.png and output/touch_controls/preview_x3.png.
The game draws these at 3x with nearest filtering, see ui/hud/.
"""
from pathlib import Path

from PIL import Image

from generate_tileset import PALETTE, rgb

HERE = Path(__file__).resolve().parent
OUT = HERE / "output" / "touch_controls"

RECESS_ALPHA = 150  # see-through centre of the parts that must not hide the world


def color(key, alpha=255):
	return (*rgb(key)[:3], alpha)


def disc(size, layers):
	"""Hard-edged concentric rings. layers: [(outer radius, painter(nx, ny))], largest first.

	nx + ny < 0 points to the top-left, where the light comes from.
	"""
	img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
	center = (size - 1) / 2
	for y in range(size):
		for x in range(size):
			dx, dy = x - center, y - center
			dist = (dx * dx + dy * dy) ** 0.5
			for radius, painter in reversed(layers):
				if dist <= radius:
					img.putpixel((x, y), painter(dx / max(dist, 1), dy / max(dist, 1)))
					break
	return img


def flat(key, alpha=255):
	return lambda nx, ny: color(key, alpha)


def lit(light, mid, shade, alpha=255, edge=0.55):
	"""Light on the top-left arc, shade on the bottom-right arc."""
	def paint(nx, ny):
		side = nx + ny
		if side < -edge:
			return color(light, alpha)
		if side > edge:
			return color(shade, alpha)
		return color(mid, alpha)
	return paint


def joystick_base():
	img = disc(64, [
		(31.5, flat("d0")),
		(30.5, lit("d5", "d4", "d3")),
		(28.5, flat("d0")),
		(27.5, flat("d0", RECESS_ALPHA)),
	])
	for x, y in tick_pixels():
		img.putpixel((x, y), color("d6"))
	return img


def tick_pixels():
	"""Small arrows just inside the ring, one per direction."""
	pixels = []
	for depth, half in ((0, 0), (1, 1), (2, 2)):
		for k in range(-half, half + 1):
			for a in (31, 32):
				# up / down
				pixels.append((a + k, 7 + depth))
				pixels.append((a + k, 56 - depth))
				# left / right
				pixels.append((7 + depth, a + k))
				pixels.append((56 - depth, a + k))
	return pixels


def joystick_knob():
	img = disc(32, [
		(15.5, flat("d0")),
		(14.5, lit("d6", "d5", "d3")),
		(11.5, flat("d5")),
	])
	return img


def action_button(pressed):
	if pressed:
		return disc(48, [
			(23.5, flat("d0")),
			(22.5, lit("d2", "d3", "d4")),
			(19.5, flat("d0")),
			(18.5, flat("d4")),
		])
	return disc(48, [
		(23.5, flat("d0")),
		(22.5, lit("d6", "d4", "d2")),
		(19.5, flat("d0")),
		(18.5, flat("d6")),
	])


def slot(selected, pressed=False):
	if selected:
		return disc(28, [
			(13.5, flat("d0")),
			(12.5, lit("wh", "y1", "f2", edge=1.2)),
			(10.5, flat("d0")),
			(9.5, flat("d5" if pressed else "d6")),
		])
	return disc(28, [
		(13.5, flat("d0")),
		(12.5, lit("d4", "d3", "d2")),
		(10.5, flat("d0")),
		(9.5, flat("d3") if pressed else flat("d0", RECESS_ALPHA)),
	])


# 5x7 digits, drawn by hand so the HUD needs no font
DIGITS = [
	["01110", "11011", "11011", "11011", "11011", "11011", "01110"],
	["00110", "01110", "00110", "00110", "00110", "00110", "01111"],
	["01110", "11011", "00011", "00110", "01100", "11000", "11111"],
	["11110", "00011", "00011", "01110", "00011", "00011", "11110"],
	["00110", "01110", "11010", "11010", "11111", "00010", "00010"],
	["11111", "11000", "11110", "00011", "00011", "11011", "01110"],
	["01110", "11000", "11110", "11011", "11011", "11011", "01110"],
	["11111", "00011", "00110", "00110", "01100", "01100", "01100"],
	["01110", "11011", "11011", "01110", "11011", "11011", "01110"],
	["01110", "11011", "11011", "11011", "01111", "00011", "01110"],
]
DIGIT_CELL = (7, 9)  # glyph plus one pixel of outline on each side


def digits():
	"""Sheet of 10 columns: row 0 is the normal colour, row 1 marks a full stock."""
	cell_w, cell_h = DIGIT_CELL
	img = Image.new("RGBA", (cell_w * 10, cell_h * 2), (0, 0, 0, 0))
	for row, key in enumerate(("d6", "y1")):
		for i, glyph in enumerate(DIGITS):
			ox, oy = i * cell_w + 1, row * cell_h + 1
			pixels = [(x, y) for y, line in enumerate(glyph) for x, ch in enumerate(line) if ch == "1"]
			for x, y in pixels:
				for dx in (-1, 0, 1):
					for dy in (-1, 0, 1):
						img.putpixel((ox + x + dx, oy + y + dy), color("d0"))
			for x, y in pixels:
				img.putpixel((ox + x, oy + y), color(key))
	return img


def check_palette(img, name):
	allowed = {rgb(k)[:3] for k in PALETTE}
	for r, g, b, a in img.get_flattened_data():
		assert a == 0 or (r, g, b) in allowed, f"{name}: ({r}, {g}, {b}) is not in the palette"


def main():
	images = {
		"joystick_base": joystick_base(),
		"joystick_knob": joystick_knob(),
		"action_button": action_button(False),
		"action_button_pressed": action_button(True),
		"slot": slot(False),
		"slot_pressed": slot(False, True),
		"slot_selected": slot(True),
		"digits": digits(),
	}
	OUT.mkdir(parents=True, exist_ok=True)
	sheet = Image.new("RGBA", (sum(i.width + 4 for i in images.values()), 64), rgb("g3"))
	x = 0
	for name, img in images.items():
		check_palette(img, name)
		img.save(OUT / f"{name}.png")
		sheet.alpha_composite(img, (x, 0))
		x += img.width + 4
	sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST).save(OUT / "preview_x3.png")
	print("OK:", OUT)


if __name__ == "__main__":
	main()
