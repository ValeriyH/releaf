class_name PixelFont
extends RefCounted
## Text from a sprite sheet, the project has no font. Upper case only, unknown characters are blank.
## Draw on a node with nearest texture filtering.

const SHEET: Texture2D = preload("res://ui/hud/res/font.png")
const CHARS: = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,:;/-_()'\"*!?+& "
const COLUMNS: = 16
const ROWS_PER_COLOR: = 4 # The gold copy of the sheet follows the normal one
const CELL: = Vector2(7.0, 9.0)
const ADVANCE: = 6.0 # Neighbouring cells share their outline column


static func width(text: String, text_scale: float) -> float:
	return (text.length() * ADVANCE + 1.0) * text_scale


static func draw(canvas: CanvasItem, text: String, pos: Vector2, text_scale: float, gold: = false) -> void:
	var cell_size: = CELL * text_scale
	for i in text.length():
		var index: = CHARS.find(text[i].to_upper())
		if index == -1:
			continue
		var cell: = Vector2(index % COLUMNS, index / COLUMNS + (ROWS_PER_COLOR if gold else 0))
		var at: = pos + Vector2(i * ADVANCE * text_scale, 0.0)
		canvas.draw_texture_rect_region(SHEET, Rect2(at, cell_size), Rect2(cell * CELL, CELL))


## pos is the middle of the text
static func draw_centered(canvas: CanvasItem, text: String, pos: Vector2, text_scale: float, gold: = false) -> void:
	var offset: = Vector2(width(text, text_scale), CELL.y * text_scale) / 2.0
	draw(canvas, text, pos - offset, text_scale, gold)
