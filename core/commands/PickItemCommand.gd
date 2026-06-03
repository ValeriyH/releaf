class_name PickItemCommand
extends Command

var item: Item

func _init(p_initiator: Node, p_item: Item) -> void:
	super(p_initiator, Events.pick_item_command.emit, Events.pick_item_processed.emit)
	self.item = p_item
