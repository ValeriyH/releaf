@abstract class_name Command
extends RefCounted

enum ExecutionStatus {
	PENDING,
	SUCCESS,
	FAILED
}

var initiator: Node
var status: ExecutionStatus = ExecutionStatus.PENDING
var message: String = ""
var command_func: Callable # The command processor
var processed_callback: Callable # The "reporter" delegate

func _init(p_initiator: Node, p_command: Callable, p_callback: Callable) -> void:
	self.initiator = p_initiator
	self.command_func = p_command
	self.processed_callback = p_callback
	
func send() -> void:
	if command_func.is_valid():
		command_func.call(self)
	else:
		push_error("ERROR: Command function not set!")
	
func set_completed(command_status :ExecutionStatus = ExecutionStatus.SUCCESS,
 command_message: String = "") -> void:
	if status != ExecutionStatus.PENDING:
		push_error("ERROR: COMPLETE ALREADY COMPLETED CONTEXT")
	self.status = command_status
	self.message = command_message
	# Automatically fire the callback if it exists!
	if processed_callback.is_valid():
		processed_callback.call(self)
	else:
		push_error("ERROR: Callback function not set!")
