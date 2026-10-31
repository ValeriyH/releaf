class_name UseItemCommand
extends Command

var item_type: Item.Type

func _init(p_initiator: Node, p_item_type: Item.Type) -> void:
	super(p_initiator, Events.use_item_command.emit, Events.use_item_processed.emit)
	self.item_type = p_item_type
