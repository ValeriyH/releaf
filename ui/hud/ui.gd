extends CanvasLayer

# Layout in reference units of a 720 px short side, thumbs rest in the bottom corners
const REFERENCE_SIDE: = 720.0
const JOYSTICK_INSET: = 150.0
const ACTION_INSET: = 130.0
const STATUS_INSET: = 16.0
const SLOT_DISTANCE: = 150.0 # From the action button centre
const SLOT_ARC_DEGREES: = Vector2(200.0, 260.0) # Fan out to the upper left, under the thumb

@onready var joystick: VirtualJoystick = $Joystick
@onready var action_button: TouchButton = $ActionButton
@onready var status_panel: StatusPanel = $StatusPanel
@onready var slots: = {
	PlayerTool.Type.Shovel: $Shovel,
	PlayerTool.Type.Extinguisher: $Extinguisher,
}


func _ready() -> void:
	visible = DisplayServer.is_touchscreen_available()
	Events.select_tool_processed.connect(on_tool_selected)
	Events.player_state_changed.connect(on_player_state_changed)
	get_viewport().size_changed.connect(layout_controls)
	layout_controls()
	SelectToolCommand.new(self, PlayerTool.Type.Extinguisher).send()


# Touch controls get out of the way for keyboard and gamepad players and return on touch.
# The status panel is not a control, so it always stays.
func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventJoypadButton:
		set_touch_controls_visible(false)
	elif event is InputEventScreenTouch:
		set_touch_controls_visible(true)


func set_touch_controls_visible(value: bool) -> void:
	joystick.visible = value
	action_button.visible = value
	for slot: TouchButton in slots.values():
		slot.visible = value


func layout_controls() -> void:
	var view: = get_viewport().get_visible_rect().size
	var ui_scale: = minf(view.x, view.y) / REFERENCE_SIDE

	# Keep clear of notches and gesture bars
	var inset_left_top: = Vector2.ZERO
	var inset_right_bottom: = Vector2.ZERO
	if OS.has_feature("mobile"):
		var screen: = Vector2(DisplayServer.screen_get_size())
		var safe: = Rect2(DisplayServer.get_display_safe_area())
		inset_left_top = safe.position * view / screen
		inset_right_bottom = (screen - safe.end) * view / screen

	joystick.set_layout(
		Rect2(0.0, 0.0, view.x / 2.0, view.y),
		Vector2(inset_left_top.x + JOYSTICK_INSET * ui_scale, view.y - inset_right_bottom.y - JOYSTICK_INSET * ui_scale),
		ui_scale
	)

	status_panel.position = inset_left_top + Vector2.ONE * STATUS_INSET * ui_scale
	status_panel.scale = Vector2.ONE * ui_scale

	var action_position: = view - inset_right_bottom - Vector2.ONE * ACTION_INSET * ui_scale
	action_button.position = action_position
	action_button.scale = Vector2.ONE * ui_scale

	var index: = 0
	for slot: TouchButton in slots.values():
		var weight: = float(index) / maxf(slots.size() - 1, 1)
		var angle: = deg_to_rad(lerpf(SLOT_ARC_DEGREES.x, SLOT_ARC_DEGREES.y, weight))
		slot.position = action_position + Vector2.from_angle(angle) * SLOT_DISTANCE * ui_scale
		slot.scale = Vector2.ONE * ui_scale
		index += 1


func on_tool_selected(cmd: SelectToolCommand) -> void:
	action_button.icon = PlayerTool.TEXTURES[cmd.tool_type]
	for tool_type: PlayerTool.Type in slots:
		slots[tool_type].selected = tool_type == cmd.tool_type


func on_player_state_changed(player: Player) -> void:
	status_panel.update_from(player)
	action_button.dimmed = not player.can_act()
	action_button.gauge = player.tank if player.selected_tool == PlayerTool.Type.Extinguisher else -1.0


func on_shovel_pressed() -> void:
	SelectToolCommand.new(self, PlayerTool.Type.Shovel).send()


func on_extinguisher_pressed() -> void:
	SelectToolCommand.new(self, PlayerTool.Type.Extinguisher).send()
