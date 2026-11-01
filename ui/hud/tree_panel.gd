class_name TreePanel
extends HudPanel
## Count of grown trees in the forest, in the top right corner.

const ICON_SCALE: = 0.75 # Fits the atlas tree into the height of StatusPanel
const PANEL_SIZE: = Vector2(108.0, StatusPanel.PANEL_SIZE.y)
const NUMBER_POSITION: = Vector2(62.0, PANEL_SIZE.y - PADDING - DIGIT_CELL.y * DIGIT_SCALE)

@export var icon: Texture2D

var count: = 0:
	set(value):
		count = value
		queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, PANEL_SIZE), COLOR_BACK)
	var icon_size: = icon.get_size() * ICON_SCALE
	draw_texture_rect(icon, Rect2(Vector2(PADDING, (PANEL_SIZE.y - icon_size.y) / 2.0), icon_size), false)
	draw_number(count, NUMBER_POSITION, false)
