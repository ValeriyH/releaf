class_name ItemSpawnContext
extends CommandContext

var item_type: Global.Items
var position: Vector2
var item_node: Node # Filled out later by the Level upon successful spawn

func _init(p_initiator: Node, p_item_type: Global.Items, p_position: Vector2) -> void:
	super(p_initiator, Events.item_spawn_processed.emit)
	self.item_type = p_item_type
	self.position = p_position
