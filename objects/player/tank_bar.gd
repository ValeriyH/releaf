class_name TankBar
extends Node2D
## Tank level above the player while it refills, whichever tool is selected.

const BAR_SIZE: = Vector2(26.0, 5.0)
const BORDER: = 1.0
const COLOR_BORDER: = Color("#342116")
const COLOR_FILL: = Color("#6CBBDB")

var level: = 1.0


func update_level(value: float, shown: bool) -> void:
	level = value
	visible = shown
	queue_redraw()


func _draw() -> void:
	var bar: = Rect2(-BAR_SIZE / 2.0, BAR_SIZE)
	draw_rect(bar, COLOR_BORDER)
	var fill: = bar.grow(-BORDER)
	fill.size.x *= level
	draw_rect(fill, COLOR_FILL)
