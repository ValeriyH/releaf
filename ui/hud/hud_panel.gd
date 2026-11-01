class_name HudPanel
extends Node2D
## Base of the HUD windows: shared look and sprite sheet digits, the project has no font.

const PADDING: = 8.0
const DIGIT_SCALE: = 2.0
const DIGIT_CELL: = Vector2(7.0, 9.0)
const COLOR_BACK: = Color("#342116", 0.55)

@export var digits_texture: Texture2D


# Digits come from a sprite sheet: row 0 is normal, row 1 marks a full stock
func draw_number(value: int, pos: Vector2, full: bool) -> void:
	var cell_size: = DIGIT_CELL * DIGIT_SCALE
	for digit in str(value):
		var region: = Rect2(Vector2(int(digit), 1 if full else 0) * DIGIT_CELL, DIGIT_CELL)
		draw_texture_rect_region(digits_texture, Rect2(pos, cell_size), region)
		pos.x += cell_size.x - DIGIT_SCALE
