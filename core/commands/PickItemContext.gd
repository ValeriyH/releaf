class_name PickItemContext
extends CommandContext

var item: Item

func _init(p_initiator: Node, p_item: Item) -> void:
	super(p_initiator, Events.pick_item_processed.emit)
	self.item = p_item
