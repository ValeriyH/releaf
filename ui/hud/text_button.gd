class_name TextButton
extends TouchButton
## Rectangular menu button with a text label.

const TEXT_SCALE: = 3.0
const BORDER: = 3.0
const COLOR_FACE: = Color("#5E351D")
const COLOR_FACE_DOWN: = Color("#342116")
const COLOR_BORDER: = Color("#342116")
const COLOR_BORDER_SELECTED: = Color("#D9A441")

var label: = ""
var button_size: = Vector2.ZERO


func _init(p_label: = "", p_size: = Vector2.ZERO) -> void:
	label = p_label
	button_size = p_size


func hits(local_point: Vector2) -> bool:
	return Rect2(-button_size / 2.0, button_size).has_point(local_point)


func _draw() -> void:
	var rect: = Rect2(-button_size / 2.0, button_size)
	draw_rect(rect, COLOR_BORDER_SELECTED if selected else COLOR_BORDER)
	draw_rect(rect.grow(-BORDER), COLOR_FACE_DOWN if finger != -1 else COLOR_FACE)
	PixelFont.draw_centered(self, label, Vector2.ZERO, TEXT_SCALE, selected)
