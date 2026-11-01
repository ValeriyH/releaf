class_name SettingsScreen
extends MenuScreen
## The gameplay values from Settings.TUNABLES. Keys and gamepad: left/right changes the row.

const PANEL_SIZE: = Vector2(900.0, 660.0)
const TITLE_Y: = -290.0
const TITLE_SCALE: = 4.0
const ROWS_Y: = -225.0
const ROW_PITCH: = 56.0
const LABEL_X: = -420.0
const MINUS_X: = 80.0
const VALUE_X: = 190.0
const PLUS_X: = 300.0
const STEP_BUTTON_SIZE: = Vector2(70.0, 48.0)
const BOTTOM_Y: = 260.0
const BOTTOM_X: = 150.0
const BOTTOM_BUTTON_SIZE: = Vector2(240.0, 60.0)
const TEXT_SCALE: = 3.0
const COLOR_PANEL: = Color("#342116", 0.9)

var row_count: = 0
var bottom_buttons: Array[TextButton] = []


func setup(on_back: Callable) -> void:
	row_count = Settings.TUNABLES.size()
	for i in row_count:
		var spec: Dictionary = Settings.TUNABLES[i]
		add_step_button("-", MINUS_X, i, spec, -spec.step)
		add_step_button("+", PLUS_X, i, spec, spec.step)
	items.clear() # Rows are selected as a whole, not by their +/- buttons
	bottom_buttons = [
		add_button("RESET", BOTTOM_BUTTON_SIZE, Vector2(-BOTTOM_X, BOTTOM_Y), on_reset_pressed),
		add_button("BACK", BOTTOM_BUTTON_SIZE, Vector2(BOTTOM_X, BOTTOM_Y), on_back),
	]


func add_step_button(label: String, x: float, row: int, spec: Dictionary, delta: float) -> void:
	add_button(label, STEP_BUTTON_SIZE, Vector2(x, row_y(row)), change.bind(spec, delta))


func row_y(row: int) -> float:
	return ROWS_Y + row * ROW_PITCH


func change(spec: Dictionary, delta: float) -> void:
	Settings.set_tunable(spec, Settings.get(spec.key) + delta)
	queue_redraw()


func on_reset_pressed() -> void:
	Settings.reset_tunables()
	queue_redraw()


# index counts the rows first, then the bottom buttons
func select(new_index: int) -> void:
	index = wrapi(new_index, 0, row_count + bottom_buttons.size())
	for i in bottom_buttons.size():
		bottom_buttons[i].selected = i + row_count == index
	queue_redraw()


func handle_input(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_up"):
		select(index - 1)
	elif event.is_action_pressed("ui_down"):
		select(index + 1)
	elif index < row_count and event.is_action_pressed("ui_left", true):
		change(Settings.TUNABLES[index], -Settings.TUNABLES[index].step)
	elif index < row_count and event.is_action_pressed("ui_right", true):
		change(Settings.TUNABLES[index], Settings.TUNABLES[index].step)
	elif index >= row_count and event.is_action_pressed("ui_accept"):
		bottom_buttons[index - row_count].pressed.emit()
	else:
		return false
	return true


func _draw() -> void:
	draw_rect(Rect2(-PANEL_SIZE / 2.0, PANEL_SIZE), COLOR_PANEL)
	PixelFont.draw_centered(self, "SETTINGS", Vector2(0.0, TITLE_Y), TITLE_SCALE, true)
	for i in row_count:
		var spec: Dictionary = Settings.TUNABLES[i]
		var y: = row_y(i)
		var chosen: = i == index
		PixelFont.draw(self, spec.label, Vector2(LABEL_X, y - PixelFont.CELL.y * TEXT_SCALE / 2.0), TEXT_SCALE, chosen)
		PixelFont.draw_centered(self, str(int(Settings.get(spec.key))), Vector2(VALUE_X, y), TEXT_SCALE, chosen)
