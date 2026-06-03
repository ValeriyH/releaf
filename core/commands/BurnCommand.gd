class_name BurnCommand
extends Command

var burn_node: Node2D
#var burn_power: int #can be set by fire how strong it is

func _init(p_initiator: Node, p_burn_node: Node2D) -> void:
	super(p_initiator, Events.burn_command.emit, Events.burn_processed.emit)
	self.burn_node = p_burn_node
