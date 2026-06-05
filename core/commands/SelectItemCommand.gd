class_name SelectItemCommand
extends Command

var item: Item.Type

func _init(p_initiator: Node, p_item: Item.Type) -> void:
	super(p_initiator, Events.select_item_command.emit, Events.select_item_processed.emit)
	self.item = p_item
