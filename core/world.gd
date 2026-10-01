extends Node2D

@onready var ItemRes: PackedScene = preload("res://objects/item/item.tscn")
@onready var TreeRes: PackedScene = preload("res://objects/tree/tree.tscn")

const Items := Item.Type
const Status: = Command.ExecutionStatus

func _ready() -> void:
	randomize()
	create_border()
	create_initial_items()
	Events.item_spawn_command.connect(on_item_spawn_command)
	Events.item_destroy_command.connect(on_item_destroy_command)
	Events.plant_tree_command.connect(on_plant_tree_command)

func create_border() -> void:
	#set default background to black (outside map)
	RenderingServer.set_default_clear_color(Color.BLACK)
	#set fade on map border
	var world: = Settings.get_world_rect()
	$Border.position = world.position
	$Border.size = world.size
	$Border.material.set_shader_parameter("rect_size", world.size)
	
	#create world barriers (StaticBody2D)
	const offset: = 10
	var static_body: = StaticBody2D.new()
	add_child(static_body)
	var boundaries: Array[Dictionary] = [
		{"pos": Vector2(world.position.x + offset, world.get_center().y), "normal": Vector2.RIGHT}, #Left
		{"pos": Vector2(world.end.x - offset, world.get_center().y),      "normal": Vector2.LEFT},  # Right
		{"pos": Vector2(world.get_center().x, world.position.y + offset), "normal": Vector2.DOWN},  # Up
		{"pos": Vector2(world.get_center().x, world.end.y - offset),      "normal": Vector2.UP}  # Down
	]
	for b in boundaries:
		var col: = CollisionShape2D.new()
		var boundary_shape: = WorldBoundaryShape2D.new()
		boundary_shape.normal = b["normal"]
		col.shape = boundary_shape
		col.global_position = b["pos"]
		static_body.add_child(col)	
	
	
func create_initial_items() -> void:
	var world_size: Rect2 = Settings.get_world_rect()
	var random_vector: = func() -> Vector2: 
		return Vector2(
			randf_range(world_size.position.x, world_size.end.x),
			randf_range(world_size.position.y, world_size.end.y)
		)
	
	for i in range(Settings.INIT_SEEDS):
		create_item(Items.Seed, random_vector.call())
	
	for i in range(Settings.INIT_ITEMS):
		var item: Items = Items[Items.keys().pick_random()]
		create_item(item, random_vector.call())

func create_item(item_name: Items, pos: Vector2) -> bool:
	var item: Node2D = ItemRes.instantiate() as Node2D
	if item:
		$Items.add_child(item)
		item.item = item_name
		item.global_position = pos
		return true
	else:
		return false
	
func on_item_spawn_command(context: ItemSpawnCommand) -> void:
	if (create_item(context.item_type, context.position)):
		context.set_completed()
	else:
		context.set_completed(Status.FAILED)
		
func on_item_destroy_command(context: ItemDestroyCommand) -> void:
	if not is_instance_valid(context.item_node) or context.item_node.is_queued_for_deletion():
		context.set_completed(Command.ExecutionStatus.FAILED, 
			"Item is already dead or invalid.")
		return
	context.item_node.queue_free()
	context.set_completed()
	
func on_plant_tree_command(cmd: PlantTreeCommand) -> void:
	var tree: Node2D = TreeRes.instantiate() as Node2D
	if tree:
		$Nature.add_child(tree)
		tree.global_position = cmd.position
		cmd.set_completed()
	else:
		cmd.set_completed(cmd.ExecutionStatus.FAILED)
