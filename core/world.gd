extends Node2D

@onready var ItemRes: PackedScene = preload("res://objects/item/item.tscn")

const Items := Item.Type
const Status: = CommandContext.ExecutionStatus

func _ready() -> void:
	randomize()
	create_initial_items()
	Events.item_spawn_command.connect(on_item_spawn_command)
	Events.item_destroy_command.connect(on_item_destroy_command)
	pass

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
	
func on_item_spawn_command(context: ItemSpawnContext) -> void:
	if (create_item(context.item_type, context.position)):
		context.set_completed()
	else:
		context.set_completed(Status.FAILED)
		
func on_item_destroy_command(context: ItemDestroyContext) -> void:
	if not is_instance_valid(context.item_node) or context.item_node.is_queued_for_deletion():
		context.set_completed(CommandContext.ExecutionStatus.FAILED, 
			"Item is already dead or invalid.")
		return
	context.item_node.queue_free()
	context.set_completed()
