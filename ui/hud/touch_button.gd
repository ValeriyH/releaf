class_name TouchButton
extends Node2D
## Round pixel-art button with its own finger tracking. It stays held until that
## finger lifts, even if the thumb slides off, so holding an action never drops.

signal pressed

const HAPTIC_MS: = 15
const GAUGE_PIPS: = 24
const GAUGE_PIP_SIZE: = 6.0
const COLOR_GAUGE: = Color("#6CBBDB")
const COLOR_GAUGE_EMPTY: = Color("#342116", 0.6)
const COLOR_DIMMED: = Color(1.0, 1.0, 1.0, 0.35)

@export var texture: Texture2D
@export var texture_pressed: Texture2D
@export var texture_selected: Texture2D
@export var icon: Texture2D:
	set(value):
		icon = value
		queue_redraw()
@export var icon_scale: = 2.0
@export var pixel_scale: = 3.0
## Larger than the sprite: thumbs land imprecisely
@export var hit_radius: = 56.0
## Input action held while the button is down
@export var action: StringName

var selected: = false:
	set(value):
		selected = value
		queue_redraw()
## The action can't do anything right now
var dimmed: = false:
	set(value):
		dimmed = value
		queue_redraw()
## Fill level 0..1 shown as pips around the button, negative hides them
var gauge: = -1.0:
	set(value):
		gauge = value
		queue_redraw()

var finger: = -1


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and finger == -1 and to_local(event.position).length() <= hit_radius:
			press(event.index)
		elif not event.pressed and event.index == finger:
			release()


func _notification(what: int) -> void:
	# The lift event never arrives when the app loses focus mid-touch
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		if finger != -1:
			release()


func _draw() -> void:
	var down: = finger != -1
	var face: = texture
	if down:
		face = texture_pressed
	elif selected and texture_selected:
		face = texture_selected
	draw_centered(face, Vector2.ZERO, pixel_scale)
	if icon:
		# Icon sinks by one sprite pixel while the button is down
		var tint: = COLOR_DIMMED if dimmed else Color.WHITE
		draw_centered(icon, Vector2(0, pixel_scale if down else 0.0), icon_scale, tint)
	if gauge >= 0.0:
		draw_gauge(face.get_width() * pixel_scale / 2.0 + GAUGE_PIP_SIZE)


func draw_centered(tex: Texture2D, pos: Vector2, tex_scale: float, tint: = Color.WHITE) -> void:
	var draw_size: = tex.get_size() * tex_scale
	draw_texture_rect(tex, Rect2(pos - draw_size / 2.0, draw_size), false, tint)


# Square pips keep the gauge pixel-art; it empties clockwise from the top
func draw_gauge(radius: float) -> void:
	for i in GAUGE_PIPS:
		var angle: = -PI / 2.0 + TAU * i / GAUGE_PIPS
		var center: = Vector2.from_angle(angle) * radius
		var lit: = float(i) / GAUGE_PIPS < gauge
		var pip: = Vector2.ONE * GAUGE_PIP_SIZE
		draw_rect(Rect2(center.round() - pip / 2.0, pip), COLOR_GAUGE if lit else COLOR_GAUGE_EMPTY)


func press(index: int) -> void:
	finger = index
	Input.vibrate_handheld(HAPTIC_MS)
	send_action(true)
	pressed.emit()
	queue_redraw()


func release() -> void:
	finger = -1
	send_action(false)
	queue_redraw()


func send_action(is_pressed: bool) -> void:
	if action.is_empty():
		return
	var event: = InputEventAction.new()
	event.action = action
	event.pressed = is_pressed
	Input.parse_input_event(event)
