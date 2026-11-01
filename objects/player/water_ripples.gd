class_name WaterRipples
extends Node2D
## Rings on the water around the player. They stay where they appeared while the player moves on.

const INTERVAL_STANDING: = 0.9
const INTERVAL_MOVING: = 0.3
const LIFETIME: = 1.0
const MAX_RADIUS: = 20.0
const FLATTEN: = 0.5 # Rings lie on the ground
const DOTS: = 28 # Square dots keep the rings pixel-art
const FEET_OFFSET: = Vector2(0.0, 8.0)
const COLOR_RING: = Color("#CDEBF2")

var active: = false
var moving: = false

var ripples: Array[Dictionary] = []
var cooldown: = 0.0

@onready var player: Player = get_parent()


func _ready() -> void:
	top_level = true
	global_position = Vector2.ZERO


func _process(delta: float) -> void:
	cooldown -= delta
	if active and cooldown <= 0.0:
		ripples.append({"position": player.global_position + FEET_OFFSET, "age": 0.0})
		cooldown = INTERVAL_MOVING if moving else INTERVAL_STANDING
	for ripple in ripples:
		ripple.age += delta
	ripples = ripples.filter(func(ripple: Dictionary) -> bool: return ripple.age < LIFETIME)
	queue_redraw()


func _draw() -> void:
	for ripple in ripples:
		var progress: float = ripple.age / LIFETIME
		var color: = Color(COLOR_RING, 1.0 - progress)
		for i in DOTS:
			var direction: = Vector2.from_angle(TAU * i / DOTS)
			var dot: Vector2 = ripple.position + Vector2(direction.x, direction.y * FLATTEN) * MAX_RADIUS * progress
			if player.background.is_water(dot):
				draw_rect(Rect2(dot.round(), Vector2.ONE), color)
