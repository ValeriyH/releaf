#!/usr/bin/env python3
"""Redraws the fire extinguisher item (32x32) with the Releaf32 palette.

Usage:  python generate_extinguisher.py        (requires: pip install pillow)
Output: output/extinguisher.png and output/extinguisher_x8.png (preview).
"""
from pathlib import Path

from PIL import Image

from generate_tileset import PALETTE, rgb

HERE = Path(__file__).resolve().parent
OUT = HERE / "output"

LEGEND = {
	"O": "d0",  # warm dark outline
	"R": "f1",  # body red
	"H": "f2",  # light rim on the body (light from the top-left)
	"S": "d2",  # shaded side of the body
	"L": "s4",  # metal highlight
	"G": "s3",  # metal
	"D": "s1",  # metal shadow
	"C": "f3",  # label
	"F": "f2",  # flame on the label
	"Y": "y1",  # flame core
	"B": "o1",  # hose
}

ART = [
	".....OOOO.......",
	"....OLLGGO......",
	".OOOOGGGGOOO....",
	"OLLLGGGGGGGDO...",
	"OGGGOOGGOODDO...",
	".OOO.OGGO.OOBBO.",
	".....ODDO.OBBO..",
	"....OOGGOOOBO...",
	"...OOOOOOOOBO...",
	"...OHRRRRSSOBO..",
	"..OHRRRRRRSSOBO.",
	"..OHRRRRRRSSOBO.",
	"..OHRRRRRRSSOBBO",
	"..OHRCCCCCSSO.OO",
	"..OHRCCFCCSSO...",
	"..OHRCFFFCSSO...",
	"..OHRFFYFCSSO...",
	"..OHRCFFCCSSO...",
	"..OHRCCCCCSSO...",
	"..OHRRRRRRSSO...",
	"..OHRRRRRRSSO...",
	"..OHRRRRRRSSO...",
	"..OHRRRRRSSSO...",
	"...OOHRRRSSO....",
	".....OOOOOO.....",
]


def main():
	width = max(len(r) for r in ART)
	assert all(len(r) == width for r in ART), "ART rows must have equal width"
	img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
	ox, oy = (32 - width) // 2, (32 - len(ART)) // 2
	for y, row in enumerate(ART):
		for x, ch in enumerate(row):
			if ch != ".":
				img.putpixel((ox + x, oy + y), rgb(LEGEND[ch]))
	OUT.mkdir(exist_ok=True)
	img.save(OUT / "extinguisher.png")
	img.resize((256, 256), Image.NEAREST).save(OUT / "extinguisher_x8.png")
	assert {v for v in LEGEND.values()} <= set(PALETTE)
	print("OK:", OUT / "extinguisher.png")


if __name__ == "__main__":
	main()
