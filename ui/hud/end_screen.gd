class_name EndScreen
extends Node2D
## Win and lose screens: pauses the game and offers the choices. Works while paused.
## Without a Continue child there is only the button back to the main menu.
## Keys and gamepad: left/right moves the gold ring, ui_accept confirms.

const MENU_SCENE: = "res://ui/main_menu/main_menu.tscn"
const INPUT_DELAY: = 0.6 # The player may be tapping action keys at the moment the game ends
const PANEL_SIZE: = Vector2(560.0, 380.0)
const COLOR_PANEL: = Color("#342116", 0.9)
const TITLE_Y: = -130.0
const TITLE_SCALE: = 5.0
const MESSAGE_Y: = -60.0
const MESSAGE_SCALE: = 3.0
const BUTTON_POSITION: = Vector2(120.0, 50.0) # Mirrored for the left button
const LABEL_Y: = 125.0
const LABEL_SCALE: = 2.0

@export var title_texture: Texture2D
@export var messages: Array[Texture2D] = []
@export var continue_label: Texture2D
@export var menu_label: Texture2D

@onready var continue_button: TouchButton = get_node_or_null("Continue")
@onready var menu_button: TouchButton = $Menu

var half_view: Vector2
var accepting: = false
var choice: TouchButton
var message: Texture2D


func _ready() -> void:
	menu_button.position = Vector2(BUTTON_POSITION.x if continue_button else 0.0, BUTTON_POSITION.y)
	if continue_button:
		continue_button.position = Vector2(-BUTTON_POSITION.x, BUTTON_POSITION.y)


## Called on every viewport change. Coordinates are in viewport space.
func set_layout(view: Vector2, ui_scale: float) -> void:
	position = view / 2.0
	scale = Vector2.ONE * ui_scale
	half_view = view / 2.0 / ui_scale
	queue_redraw()


func open(message_index: = 0) -> void:
	message = messages[message_index]
	visible = true
	get_tree().paused = true
	set_buttons_visible(false)
	select(continue_button if continue_button else menu_button)
	queue_redraw()
	await get_tree().create_timer(INPUT_DELAY).timeout
	set_buttons_visible(true)
	accepting = true


func set_buttons_visible(value: bool) -> void:
	menu_button.visible = value
	if continue_button:
		continue_button.visible = value


func select(button: TouchButton) -> void:
	if button == null:
		return
	choice = button
	menu_button.selected = button == menu_button
	if continue_button:
		continue_button.selected = button == continue_button


func _input(event: InputEvent) -> void:
	if not accepting or not (event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_accept")):
		return
	# Unpausing must not hand the same key press to the player. Comes first: the menu replaces this scene
	get_viewport().set_input_as_handled()
	if event.is_action_pressed("ui_left"):
		select(continue_button)
	elif event.is_action_pressed("ui_right"):
		select(menu_button)
	else:
		choice.pressed.emit()


func _draw() -> void:
	draw_rect(Rect2(-half_view, half_view * 2.0), HudPanel.COLOR_BACK)
	draw_rect(Rect2(-PANEL_SIZE / 2.0, PANEL_SIZE), COLOR_PANEL)
	draw_centered(title_texture, Vector2(0.0, TITLE_Y), TITLE_SCALE)
	if message:
		draw_centered(message, Vector2(0.0, MESSAGE_Y), MESSAGE_SCALE)
	if continue_button:
		draw_centered(continue_label, Vector2(-BUTTON_POSITION.x, LABEL_Y), LABEL_SCALE)
	draw_centered(menu_label, Vector2(menu_button.position.x, LABEL_Y), LABEL_SCALE)


func draw_centered(texture: Texture2D, pos: Vector2, texture_scale: float) -> void:
	var draw_size: = texture.get_size() * texture_scale
	draw_texture_rect(texture, Rect2(pos - draw_size / 2.0, draw_size), false)


func on_continue_pressed() -> void:
	accepting = false
	visible = false
	get_tree().paused = false


func on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)
