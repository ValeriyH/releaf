class_name SelectToolCommand
extends Command

var tool_type: PlayerTool.Type

func _init(p_initiator: Node, p_tool_type: PlayerTool.Type) -> void:
	super(p_initiator, Events.select_tool_command.emit, Events.select_tool_processed.emit)
	self.tool_type = p_tool_type
