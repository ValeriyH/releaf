extends Node2D

@onready var ItemRes: PackedScene = preload("res://objects/item/item.tscn")
@onready var TreeRes: PackedScene = preload("res://objects/tree/tree.tscn")
@onready var FireRes: PackedScene = preload("res://objects/fire/fire.tscn")

const Items := Item.Type
const Status: = Command.ExecutionStatus
const FIRE_MIN_START_DISTANCE: = 400.0 # From the player

var won: = false # The player may keep playing after a win, it is announced once

func _ready() -> void:
	randomize()
	create_border()
	create_initial_items()
	adjust_fire_count()
	Events.item_spawn_command.connect(on_item_spawn_command)
	Events.item_destroy_command.connect(on_item_destroy_command)
	Events.plant_tree_command.connect(on_plant_tree_command)
	Events.tree_grown.connect(on_tree_grown)
	Events.burn_processed.connect(on_burn_processed)

# The fires placed in the scene are the base, the setting removes some or adds random ones
func adjust_fire_count() -> void:
	var wanted: = int(Settings.fire_count)
	while $Enemies.get_child_count() > wanted:
		var fire: = $Enemies.get_child($Enemies.get_child_count() - 1)
		$Enemies.remove_child(fire)
		fire.queue_free()
	var world_size: = Settings.get_world_rect()
	while $Enemies.get_child_count() < wanted:
		var pos: = Vector2(
			randf_range(world_size.position.x, world_size.end.x),
			randf_range(world_size.position.y, world_size.end.y)
		)
		if not $Background.is_water(pos) and pos.distance_to($Player.global_position) >= FIRE_MIN_START_DISTANCE:
			var fire: Node2D = FireRes.instantiate()
			$Enemies.add_child(fire)
			fire.global_position = pos

func on_burn_processed(_cmd: BurnCommand) -> void:
	if get_tree().get_node_count_in_group(Global.LIVING_TREES_GROUP) == 0:
		Events.game_lost.emit(Global.LoseReason.FOREST_BURNED)

func on_tree_grown() -> void:
	if not won and get_tree().get_node_count_in_group(Global.GROWN_TREES_GROUP) >= Settings.trees_to_win:
		won = true
		Events.game_won.emit()

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
	
	var seeds: = int(Settings.items_at_start) / 2
	for i in range(seeds):
		create_item(Items.Seed, random_vector.call())

	for i in range(int(Settings.items_at_start) - seeds):
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
		tree.grown = false
		$Nature.add_child(tree)
		tree.global_position = cmd.position
		cmd.set_completed()
	else:
		cmd.set_completed(cmd.ExecutionStatus.FAILED)
