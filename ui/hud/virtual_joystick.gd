class_name VirtualJoystick
extends Node2D
## Floating joystick: the base appears under the thumb anywhere in `zone` and
## follows it when the thumb goes past the rim, so reversing is always one short move.

const DEADZONE: = 0.12 # Fractions of the knob travel
const FULL_SPEED_AT: = 0.7
const MIN_STRENGTH: = 0.35
const IDLE_ALPHA: = 0.45
const ACTIVE_ALPHA: = 0.95
const RETURN_SPEED: = 1800.0
const FADE_SPEED: = 6.0
const TRAVEL_RATIO: = 0.875 # Knob stops at the inner edge of the ring

@export var base_texture: Texture2D
@export var knob_texture: Texture2D
@export var pixel_scale: = 3.0

var zone: Rect2
var rest_position: Vector2
var ui_scale: = 1.0

var finger: = -1
var center: Vector2
var knob_offset: Vector2


## Called on every viewport change. Coordinates are in viewport space.
func set_layout(p_zone: Rect2, p_rest_position: Vector2, p_ui_scale: float) -> void:
	zone = p_zone
	rest_position = p_rest_position
	ui_scale = p_ui_scale
	if finger == -1:
		center = rest_position
	queue_redraw()


func _ready() -> void:
	modulate.a = IDLE_ALPHA


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and finger == -1 and zone.has_point(event.position):
			finger = event.index
			center = clamp_to_screen(event.position)
			move_knob(event.position)
		elif not event.pressed and event.index == finger:
			release()
	elif event is InputEventScreenDrag and event.index == finger:
		move_knob(event.position)


func _process(delta: float) -> void:
	var target_alpha: = IDLE_ALPHA if finger == -1 else ACTIVE_ALPHA
	modulate.a = move_toward(modulate.a, target_alpha, FADE_SPEED * delta)
	if finger == -1 and center != rest_position:
		center = center.move_toward(rest_position, RETURN_SPEED * ui_scale * delta)
		queue_redraw()


func _notification(what: int) -> void:
	# The lift event never arrives when the app loses focus mid-touch
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		if finger != -1:
			release()


func _draw() -> void:
	draw_centered(base_texture, center)
	draw_centered(knob_texture, center + knob_offset)


func draw_centered(texture: Texture2D, pos: Vector2) -> void:
	var draw_size: = texture.get_size() * pixel_scale * ui_scale
	draw_texture_rect(texture, Rect2(pos - draw_size / 2.0, draw_size), false)


func get_travel() -> float:
	return base_texture.get_width() / 2.0 * pixel_scale * ui_scale * TRAVEL_RATIO


func clamp_to_screen(pos: Vector2) -> Vector2:
	var margin: = base_texture.get_width() / 2.0 * pixel_scale * ui_scale
	var screen: = get_viewport_rect().grow(-margin)
	return pos.clamp(screen.position, screen.end)


func move_knob(pos: Vector2) -> void:
	var travel: = get_travel()
	var offset: = pos - center
	if offset.length() > travel:
		center = clamp_to_screen(pos - offset.limit_length(travel))
		offset = (pos - center).limit_length(travel)
	knob_offset = offset
	apply_direction(offset / travel)
	queue_redraw()


func apply_direction(tilt: Vector2) -> void:
	var amount: = tilt.length()
	var output: = Vector2.ZERO
	if amount > DEADZONE:
		var strength: = remap(minf(amount, FULL_SPEED_AT), DEADZONE, FULL_SPEED_AT, MIN_STRENGTH, 1.0)
		output = tilt.normalized() * strength
	set_action("ui_left", -output.x)
	set_action("ui_right", output.x)
	set_action("ui_up", -output.y)
	set_action("ui_down", output.y)


func set_action(action: StringName, strength: float) -> void:
	if strength > 0.0:
		Input.action_press(action, strength)
	else:
		Input.action_release(action)


func release() -> void:
	finger = -1
	knob_offset = Vector2.ZERO
	apply_direction(Vector2.ZERO)
	queue_redraw()
