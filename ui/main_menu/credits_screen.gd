class_name CreditsScreen
extends MenuScreen
## Assets and their licences, see assets/ASSET_SOURCES.md. Scrolls by drag and by up/down.

const PANEL_SIZE: = Vector2(900.0, 660.0)
const TITLE_Y: = -290.0
const TITLE_SCALE: = 4.0
const LINES_TOP: = -250.0
const LINES_BOTTOM: = 220.0
const LINE_PITCH: = 24.0
const TEXT_SCALE: = 2.0
const TEXT_X: = -420.0
const WRAP_COLUMNS: = 68
const SCROLL_SPEED: = 300.0
const BACK_Y: = 275.0
const BACK_SIZE: = Vector2(240.0, 56.0)
const COLOR_PANEL: = Color("#342116", 0.9)

# A line starting with "#" is a heading
const CREDITS: = [
	"# TREES AND STONES",
	"LPC TILE ATLAS, COMPILED BY ADRIX89",
	"OPENGAMEART.ORG/CONTENT/LPC-TILE-ATLAS",
	"LICENCE: CC-BY-SA 3.0 OR GNU GPL 3.0",
	"CREATIVECOMMONS.ORG/LICENSES/BY-SA/3.0",
	"GNU.ORG/LICENSES/GPL-3.0.HTML",
	"",
	"AUTHORS OF THE ATLAS:",
	"LANEA ZIMMERMAN (SHARM)",
	"STEPHEN CHALLENER (REDSHRIKE)",
	"CHARLES SANCHEZ (CHARLESGABRIEL)",
	"MANUEL RIECKE (MRBEAST)",
	"DANIEL ARMSTRONG (HUGHSPECTRUM)",
	"CASPER NILSSON (GNU GPL 3.0 OR LATER)",
	"DANIEL EDDELAND (GNU GPL 3.0 OR LATER)",
	"JOHANN CHARLOT (GNU LGPL 3 OR LATER)",
	"SKYLER ROBERT COLLADAY",
	"",
	"# FOX",
	"ANSIMUZ, SUNNYLAND PACK, CC0 1.0",
	"ANSIMUZ.ITCH.IO/SUNNY-LAND-PIXEL-GAME-ART",
	"",
	"# FIRE ANIMATION",
	"TAURAN, CC0",
	"OPENGAMEART.ORG/CONTENT/ANIMATED-FLAME-TEXTURE",
	"",
	"# FIRE SOUNDS",
	"PAGDEV, CC0",
	"OPENGAMEART.ORG/CONTENT/FIREPLACE-SOUND-LOOP",
	"",
	"# GODOT ENGINE",
	"MIT LICENCE, GODOTENGINE.ORG/LICENSE",
]

var lines: PackedStringArray = []
var scroll: = 0.0


func setup(on_back: Callable) -> void:
	add_button("BACK", BACK_SIZE, Vector2(0.0, BACK_Y), on_back)
	lines.append_array(CREDITS)
	for paragraph in Engine.get_license_text().split("\n\n"):
		lines.append("")
		lines.append_array(wrap_text(paragraph.replace("\n", " ")))


func wrap_text(text: String) -> PackedStringArray:
	var result: PackedStringArray = []
	var line: = ""
	for word in text.split(" ", false):
		if line.length() + word.length() + 1 > WRAP_COLUMNS:
			result.append(line)
			line = ""
		line += (" " if not line.is_empty() else "") + word
	result.append(line)
	return result


func open() -> void:
	scroll = 0.0
	super()


func set_scroll(value: float) -> void:
	var content: = lines.size() * LINE_PITCH
	scroll = clampf(value, 0.0, maxf(content - (LINES_BOTTOM - LINES_TOP), 0.0))
	queue_redraw()


func _process(delta: float) -> void:
	if is_visible_in_tree():
		var direction: = Input.get_axis("ui_up", "ui_down")
		if direction != 0.0:
			set_scroll(scroll + direction * SCROLL_SPEED * delta)


# The only button stays selected, up/down scroll in _process
func handle_input(event: InputEvent) -> bool:
	if event is InputEventScreenDrag:
		set_scroll(scroll - event.relative.y / scale.y)
		return true
	if event.is_action_pressed("ui_accept"):
		items[0].pressed.emit()
		return true
	return false


func _draw() -> void:
	draw_rect(Rect2(-PANEL_SIZE / 2.0, PANEL_SIZE), COLOR_PANEL)
	PixelFont.draw_centered(self, "CREDITS", Vector2(0.0, TITLE_Y), TITLE_SCALE, true)
	for i in lines.size():
		var y: = LINES_TOP + i * LINE_PITCH - scroll
		if y < LINES_TOP or y > LINES_BOTTOM:
			continue
		var heading: = lines[i].begins_with("#")
		PixelFont.draw(self, lines[i].trim_prefix("# "), Vector2(TEXT_X, y), TEXT_SCALE, heading)
