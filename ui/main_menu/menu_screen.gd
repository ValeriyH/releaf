class_name MenuScreen
extends Node2D
## One page of the main menu. Coordinates are in units of a 720 px short side around the screen centre.
## Keys and gamepad: up/down moves the gold frame, ui_accept confirms.

var items: Array[TextButton] = []
var index: = 0


func add_button(label: String, button_size: Vector2, pos: Vector2, action: Callable) -> TextButton:
	var button: = TextButton.new(label, button_size)
	button.position = pos
	button.pressed.connect(action)
	add_child(button)
	items.append(button)
	return button


func set_layout(view: Vector2, ui_scale: float) -> void:
	position = view / 2.0
	scale = Vector2.ONE * ui_scale


func open() -> void:
	visible = true
	select(0)


func select(new_index: int) -> void:
	index = wrapi(new_index, 0, items.size())
	for i in items.size():
		items[i].selected = i == index


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var viewport: = get_viewport() # Taken first: START leaves the tree
	if handle_input(event):
		# Pressing can open another page, which must not react to the same press
		viewport.set_input_as_handled()


## Returns true if the event was used
func handle_input(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_up"):
		select(index - 1)
	elif event.is_action_pressed("ui_down"):
		select(index + 1)
	elif event.is_action_pressed("ui_accept"):
		items[index].pressed.emit()
	else:
		return false
	return true
