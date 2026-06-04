class_name FireQuenchCommand
extends Command

var fire_node: Node2D
#var power: int #can be set to power

func _init(p_initiator: Node, p_fire_node: Node2D) -> void:
	super(p_initiator, Events.fire_quench_command.emit, Events.fire_quench_processed.emit)
	self.fire_node = p_fire_node
