class_name ItemDestroyContext
extends CommandContext

enum DestroyReason { PICKED_UP, BURNED, DECAYED }

var item_node: Node2D
var reason: DestroyReason

func _init(p_initiator: Node, p_item_node: Node2D, p_reason: DestroyReason) -> void:
	# Automatically wire it to report its final result back to the global processed stream
	super(p_initiator, Events.item_destroy_processed.emit)
	self.item_node = p_item_node
	self.reason = p_reason
