extends CanvasLayer
## The start screen and its pages, the project's main scene. The game starts in res://main.tscn.

const GAME_SCENE: = "res://main.tscn"
const REFERENCE_SIDE: = 720.0
const TITLE_Y: = -190.0
const TITLE_SCALE: = 12.0
const BUTTON_SIZE: = Vector2(340.0, 72.0)
const FIRST_BUTTON_Y: = -40.0
const BUTTON_PITCH: = 92.0

var start_screen: StartScreen
var settings_screen: SettingsScreen
var credits_screen: CreditsScreen


class StartScreen extends MenuScreen:
	func _draw() -> void:
		PixelFont.draw_centered(self, "RELEAF", Vector2(0.0, TITLE_Y), TITLE_SCALE, true)


func _ready() -> void:
	start_screen = add_screen(StartScreen.new())
	start_screen.add_button("START", BUTTON_SIZE, Vector2(0.0, FIRST_BUTTON_Y), on_start_pressed)
	start_screen.add_button("SETTINGS", BUTTON_SIZE, Vector2(0.0, FIRST_BUTTON_Y + BUTTON_PITCH), show_screen.bind(1))
	start_screen.add_button("CREDITS", BUTTON_SIZE, Vector2(0.0, FIRST_BUTTON_Y + BUTTON_PITCH * 2.0), show_screen.bind(2))
	settings_screen = add_screen(SettingsScreen.new())
	settings_screen.setup(show_screen.bind(0))
	credits_screen = add_screen(CreditsScreen.new())
	credits_screen.setup(show_screen.bind(0))
	get_viewport().size_changed.connect(layout_screens)
	layout_screens()
	show_screen(0)


func add_screen(screen: MenuScreen) -> MenuScreen:
	screen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(screen)
	return screen


func layout_screens() -> void:
	var view: = get_viewport().get_visible_rect().size
	var ui_scale: = minf(view.x, view.y) / REFERENCE_SIDE
	for screen: MenuScreen in get_children():
		screen.set_layout(view, ui_scale)


func show_screen(page: int) -> void:
	for screen: MenuScreen in get_children():
		screen.visible = false
	var screen: MenuScreen = get_child(page)
	screen.open()


func on_start_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
