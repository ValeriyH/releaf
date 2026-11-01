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
@onready var tree_panel: TreePanel = $TreePanel
@onready var win_screen: EndScreen = $WinScreen
@onready var lose_screen: EndScreen = $LoseScreen
@onready var slots: = {
	PlayerTool.Type.Shovel: $Shovel,
	PlayerTool.Type.Extinguisher: $Extinguisher,
}


func _ready() -> void:
	visible = DisplayServer.is_touchscreen_available()
	Events.select_tool_processed.connect(on_tool_selected)
	Events.player_state_changed.connect(on_player_state_changed)
	Events.tree_grown.connect(update_tree_count)
	Events.burn_processed.connect(update_tree_count)
	Events.game_won.connect(on_game_won)
	Events.game_lost.connect(on_game_lost)
	get_viewport().size_changed.connect(layout_controls)
	layout_controls()
	update_tree_count()
	SelectToolCommand.new(self, PlayerTool.Type.Extinguisher).send()


# The joystick gets out of the way for keyboard and gamepad players and returns on touch.
# Tool slots and the action button stay: they show the selected tool and the tank.
func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventJoypadButton:
		joystick.visible = false
	elif event is InputEventScreenTouch:
		joystick.visible = true


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

	tree_panel.position = Vector2(
		view.x - inset_right_bottom.x - (STATUS_INSET + TreePanel.PANEL_SIZE.x) * ui_scale,
		inset_left_top.y + STATUS_INSET * ui_scale
	)
	tree_panel.scale = Vector2.ONE * ui_scale

	win_screen.set_layout(view, ui_scale)
	lose_screen.set_layout(view, ui_scale)

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


func update_tree_count(_cmd: Command = null) -> void:
	tree_panel.count = get_tree().get_node_count_in_group(Global.GROWN_TREES_GROUP)


func on_game_won() -> void:
	end_game(win_screen)


func on_game_lost(reason: Global.LoseReason) -> void:
	end_game(lose_screen, reason)


# Two endings can come in one frame, the first one stays.
# Paused controls never see the finger lift, a held one would stay pressed after the pause.
func end_game(screen: EndScreen, message_index: = 0) -> void:
	if get_tree().paused:
		return
	joystick.release()
	action_button.release()
	for slot: TouchButton in slots.values():
		slot.release()
	screen.open(message_index)


func on_shovel_pressed() -> void:
	SelectToolCommand.new(self, PlayerTool.Type.Shovel).send()


func on_extinguisher_pressed() -> void:
	SelectToolCommand.new(self, PlayerTool.Type.Extinguisher).send()
