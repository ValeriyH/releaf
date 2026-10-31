#!/usr/bin/env python3
"""Draws the shovel tool and the seed, refill and medkit items (32x32) with the Releaf32 palette.

Usage:  python generate_items.py        (requires: pip install pillow)
Output: output/items/*.png and output/items/preview_x4.png.
The medkit uses a green cross on purpose: the red cross on white is a protected emblem.
"""
from pathlib import Path

from PIL import Image

from generate_tileset import PALETTE, rgb

HERE = Path(__file__).resolve().parent
OUT = HERE / "output" / "items"

SHOVEL = (
	{
		"O": "d0",  # warm dark outline
		"H": "d5",  # handle, lit side
		"D": "d3",  # handle, shaded side
		"S": "s2",  # collar
		"L": "s4",  # blade highlight
		"G": "s3",  # blade
		"K": "s1",  # blade shadow
	},
	[
		"...OOOOO...",
		"..OHHHDDO..",
		"...OOHOO...",
		"....OHO....",
		"....OHDO...",
		"....OHDO...",
		"....OHDO...",
		"....OHDO...",
		"....OHDO...",
		"....OHDO...",
		"....OHDO...",
		"....OHDO...",
		"....OHDO...",
		"....OHDO...",
		"...OSSSO...",
		"..OOSSSOO..",
		".OLLGGGGKO.",
		".OLGGGGGKO.",
		".OLGGGGGKO.",
		".OLGGGGGKO.",
		".OLGGGGGKO.",
		".OLGGGGGKO.",
		"..OLGGGKO..",
		"...OLGKO...",
		"....OOO....",
	],
)

REFILL = (
	{
		"O": "d0",
		"L": "s4",  # valve highlight
		"G": "s3",  # valve
		"K": "s1",  # valve shadow
		"H": "w3",  # light rim on the body (light from the top-left)
		"W": "w1",  # body
		"S": "w0",  # shaded side of the body
		"C": "w4",  # drop on the label
	},
	[
		".....OOOO.....",
		"....OLLGGO....",
		"....OGGKKO....",
		".....OGKO.....",
		"...OOOOOOOO...",
		"..OHHWWWWSSO..",
		".OHWWWWWWWWSO.",
		".OHWWWWWWWWSO.",
		".OHWWWCCWWWSO.",
		".OHWWWCCWWWSO.",
		".OHWWCCCCWWSO.",
		".OHWWCCCCWWSO.",
		".OHWWWCCWWWSO.",
		".OHWWWWWWWWSO.",
		".OHWWWWWWWWSO.",
		".OHWWWWWWWSSO.",
		"..OOHWWWWSOO..",
		"....OOOOOO....",
	],
)

MEDKIT = (
	{
		"O": "d0",
		"D": "d3",  # handle
		"H": "wh",  # highlight
		"L": "d6",  # case
		"S": "d4",  # shaded side of the case
		"G": "g2",  # cross
	},
	[
		".......OOOOOO.......",
		"......ODDDDDDO......",
		"......OD....DO......",
		".OOOOOOOOOOOOOOOOOO.",
		"OHHHHHHHHHHHHHHHHHSO",
		"OHLLLLLLLLLLLLLLLLSO",
		"OHLLLLLLLGGLLLLLLLSO",
		"OHLLLLLLLGGLLLLLLLSO",
		"OHLLLLLLLGGLLLLLLLSO",
		"OHLLLGGGGGGGGGGLLLSO",
		"OHLLLGGGGGGGGGGLLLSO",
		"OHLLLLLLLGGLLLLLLLSO",
		"OHLLLLLLLGGLLLLLLLSO",
		"OHLLLLLLLGGLLLLLLLSO",
		"OHLLLLLLLLLLLLLLLLSO",
		"OSSSSSSSSSSSSSSSSSSO",
		".OOOOOOOOOOOOOOOOOO.",
	],
)


SEED = (
	{
		"O": "d0",
		"K": "d2",  # cap
		"C": "d1",  # cap scales
		"H": "d6",  # light rim on the nut (light from the top-left)
		"L": "d4",  # nut
		"S": "d3",  # shaded side of the nut
	},
	[
		".......OO.......",
		".......OKO......",
		"....OOOOOOOO....",
		"..OOKKCKKCKKOO..",
		".OKCKKCKKCKKCKO.",
		".OKKCKKCKKCKKKO.",
		".OOOOOOOOOOOOOO.",
		"..OHLLLLLLLLSO..",
		"..OHLLLLLLLLSO..",
		"..OHLLLLLLLSSO..",
		"..OHLLLLLLLSSO..",
		"...OHLLLLLSSO...",
		"...OHLLLLLSSO...",
		"....OHLLLSSO....",
		".....OLLSSO.....",
		"......OLSO......",
		".......OO.......",
	],
)


def draw(legend, art):
	width = max(len(r) for r in art)
	assert all(len(r) == width for r in art), "ART rows must have equal width"
	assert set(legend.values()) <= set(PALETTE)
	img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
	ox, oy = (32 - width) // 2, (32 - len(art)) // 2
	for y, row in enumerate(art):
		for x, ch in enumerate(row):
			if ch != ".":
				img.putpixel((ox + x, oy + y), rgb(legend[ch]))
	return img


def main():
	images = {"shovel": draw(*SHOVEL), "seed": draw(*SEED), "refill": draw(*REFILL), "medkit": draw(*MEDKIT)}
	OUT.mkdir(parents=True, exist_ok=True)
	sheet = Image.new("RGBA", (36 * len(images), 32), rgb("g3"))
	for i, (name, img) in enumerate(images.items()):
		img.save(OUT / f"{name}.png")
		sheet.alpha_composite(img, (i * 36, 0))
	sheet.resize((sheet.width * 4, sheet.height * 4), Image.NEAREST).save(OUT / "preview_x4.png")
	print("OK:", OUT)


if __name__ == "__main__":
	main()
