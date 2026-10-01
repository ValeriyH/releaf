extends Node2D
## World boundary with collision walls and visual smoke/dark gradient.

const WALL_THICKNESS := 40.0
const GRADIENT_MARGIN := 200.0
const GRADIENT_EXTEND := 600.0

var world_rect: Rect2

func _ready() -> void:
	world_rect = Settings.get_world_rect()
	_create_outside_darkness()
	_create_collision_walls()
	_create_visual_gradient()

func _create_collision_walls() -> void:
	var body := StaticBody2D.new()
	body.name = "BoundaryBody"
	body.collision_layer = 1  # OBSTACLE layer
	body.collision_mask = 0
	add_child(body)

	# Top wall
	var top := CollisionShape2D.new()
	top.name = "TopWall"
	top.position = Vector2(world_rect.position.x + world_rect.size.x / 2, world_rect.position.y)
	var top_shape := RectangleShape2D.new()
	top_shape.size = Vector2(world_rect.size.x + WALL_THICKNESS * 2, WALL_THICKNESS)
	top.shape = top_shape
	body.add_child(top)

	# Bottom wall
	var bottom := CollisionShape2D.new()
	bottom.name = "BottomWall"
	bottom.position = Vector2(world_rect.position.x + world_rect.size.x / 2, world_rect.end.y)
	var bottom_shape := RectangleShape2D.new()
	bottom_shape.size = Vector2(world_rect.size.x + WALL_THICKNESS * 2, WALL_THICKNESS)
	bottom.shape = bottom_shape
	body.add_child(bottom)

	# Left wall
	var left := CollisionShape2D.new()
	left.name = "LeftWall"
	left.position = Vector2(world_rect.position.x, world_rect.position.y + world_rect.size.y / 2)
	var left_shape := RectangleShape2D.new()
	left_shape.size = Vector2(WALL_THICKNESS, world_rect.size.y + WALL_THICKNESS * 2)
	left.shape = left_shape
	body.add_child(left)

	# Right wall
	var right := CollisionShape2D.new()
	right.name = "RightWall"
	right.position = Vector2(world_rect.end.x, world_rect.position.y + world_rect.size.y / 2)
	var right_shape := RectangleShape2D.new()
	right_shape.size = Vector2(WALL_THICKNESS, world_rect.size.y + WALL_THICKNESS * 2)
	right.shape = right_shape
	body.add_child(right)

func _create_visual_gradient() -> void:
	var texture := _create_gradient_texture()
	var sprite := Sprite2D.new()
	sprite.name = "BoundaryGradient"
	sprite.texture = texture
	sprite.centered = false
	sprite.position = world_rect.position - Vector2(GRADIENT_EXTEND, GRADIENT_EXTEND)
	var total_size := world_rect.size + Vector2(GRADIENT_EXTEND * 2, GRADIENT_EXTEND * 2)
	sprite.scale = Vector2(total_size.x / texture.get_width(), total_size.y / texture.get_height())
	sprite.z_index = 100
	add_child(sprite)

func _create_outside_darkness() -> void:
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.set_pixel(0, 0, Color(1, 1, 1, 1))
	var texture := ImageTexture.create_from_image(image)

	var sprite := Sprite2D.new()
	sprite.name = "OutsideDarkness"
	sprite.texture = texture
	sprite.centered = false
	sprite.position = Vector2(-5000, -5000)
	sprite.scale = Vector2(10000, 10000)
	sprite.modulate = Color(0.02, 0.02, 0.05, 1)
	sprite.z_index = -15
	add_child(sprite)

func _create_gradient_texture() -> ImageTexture:
	var width := 512
	var height := 512
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)

	for x in range(width):
		for y in range(height):
			var dist: float = min(x, y, width - x, height - y)
			var alpha := 1.0 - smoothstep(0, GRADIENT_MARGIN, dist)
			var noise := randf_range(-0.08, 0.08)
			alpha = clamp(alpha + noise * alpha, 0.0, 0.85)
			image.set_pixel(x, y, Color(0.02, 0.02, 0.05, alpha))

	return ImageTexture.create_from_image(image)
