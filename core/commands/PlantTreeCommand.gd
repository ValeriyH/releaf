class_name PlantTreeCommand
extends Command

var item_type: int
var position: Vector2
var item_node: Node # Filled out later by the Level upon successful spawn

func _init(p_initiator: Node, p_position: Vector2) -> void:
	super(p_initiator,
		Events.plant_tree_command.emit,
		Events.plant_tree_processed.emit)
	self.position = p_position
