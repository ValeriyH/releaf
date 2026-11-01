class_name StatusPanel
extends HudPanel
## Health bar and item stock in the top left corner, away from both thumbs.

const ITEMS: = [Item.Type.Seed, Item.Type.Refill, Item.Type.Medkit]
const BAR_SIZE: = Vector2(258.0, 18.0)
const BAR_BORDER: = 3.0
const ICON_SCALE: = 2.0
const ICON_SIZE: = 32.0 * ICON_SCALE
const COLUMN_WIDTH: = 86.0
const PANEL_SIZE: = Vector2(BAR_SIZE.x, BAR_SIZE.y + ICON_SIZE) + Vector2.ONE * PADDING * 2.0

# Palette colours (Releaf32)
const COLOR_BORDER: = Color("#342116")
const COLOR_HEALTH: = Color("#64A42C")
const COLOR_HEALTH_LOW: = Color("#E87838")
const COLOR_EMPTY_ICON: = Color(1.0, 1.0, 1.0, 0.35)

var health_ratio: = 1.0
var health_low: = false
var stock: Dictionary = {}


func update_from(player: Player) -> void:
	health_ratio = player.health / Settings.max_health
	health_low = player.health <= Settings.MEDKIT_USE_AT
	stock = player.stock
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, PANEL_SIZE), COLOR_BACK)

	var bar: = Rect2(Vector2.ONE * PADDING, BAR_SIZE)
	draw_rect(bar, COLOR_BORDER)
	var fill: = bar.grow(-BAR_BORDER)
	fill.size.x *= health_ratio
	draw_rect(fill, COLOR_HEALTH_LOW if health_low else COLOR_HEALTH)

	if stock.is_empty():
		return
	var pos: = Vector2(PADDING, PADDING + BAR_SIZE.y)
	for item: Item.Type in ITEMS:
		var count: int = stock[item]
		var tint: = Color.WHITE if count > 0 else COLOR_EMPTY_ICON
		draw_texture_rect(Item.TEXTURES[item], Rect2(pos, Vector2.ONE * ICON_SIZE), false, tint)
		draw_number(count, pos + Vector2(ICON_SIZE - 10.0, ICON_SIZE - DIGIT_CELL.y * DIGIT_SCALE), count >= Settings.STOCK_LIMITS[item])
		pos.x += COLUMN_WIDTH
