class_name CommandContext
extends RefCounted

enum ExecutionStatus {
	PENDING,
	SUCCESS,
	FAILED
}

var initiator: Node
var status: ExecutionStatus = ExecutionStatus.PENDING
var message: String = ""
var processed_callback: Callable # The "reporter" delegate

func _init(p_initiator: Node, p_callback: Callable) -> void:
	self.initiator = p_initiator
	self.processed_callback = p_callback
	
func set_completed(command_status :ExecutionStatus = ExecutionStatus.SUCCESS,
 command_message: String = "") -> void:
	if status != ExecutionStatus.PENDING:
		printerr("ERROR: COMPLETE ALREADY COMPLETED CONTEXT")
	self.status = command_status
	self.message = command_message
	# Automatically fire the callback if it exists!
	if processed_callback.is_valid():
		processed_callback.call(self)
