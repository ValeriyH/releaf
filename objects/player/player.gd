extends CharacterBody2D
class_name Player

var base_speed: = 200
var direction: Vector2 = Vector2()

func _ready() -> void:
	Events.burn_command.connect(on_burn)
	Events.pick_item_processed.connect(on_pick_item)
	Events.plant_tree_processed.connect(on_plant_tree)

func _input(event: InputEvent) -> void:
	if (event is not InputEventKey):
		return
	
	direction = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	
	if event.is_action_pressed("ui_accept"):
		var pos: Vector2 = $ActionBox/Sprite2D.global_position
		var plant: = PlantTreeCommand.new(self, pos)
		plant.send()
	
	if (direction.x == 0 and direction.y == 0):
		$Sprite.pause()
	else:
		if (!$Sprite.is_playing()):
			$Sprite.play("move")
		$Sprite.flip_h = direction.x < 0
		direction = direction.normalized() * base_speed
		if direction.x != 0:
			$ActionBox.position.x = abs($ActionBox.position.x) * sign(direction.x)

func _process(delta: float) -> void:
	move_and_collide(direction * delta)

func on_action_box_body_entered(node: Node2D) -> void:
	print("Player area " + node.name)
	if node is Item:
		var item: = node as Item
		var cmd: = PickItemCommand.new(self, item)
		cmd.send()

func on_pick_item(cmd: PickItemCommand) -> void:
	if cmd.initiator == self:
		print("Picked item " + cmd.item.name)

func on_burn(ctx: BurnCommand) -> void:
	if ctx.burn_node == self:
		print("Player at fire!!!")
		pass

func on_plant_tree(cmd: PlantTreeCommand) -> void:
	if cmd.initiator == self and cmd.status == cmd.ExecutionStatus.SUCCESS:
		print("Player plant tree")
		#Update inventory
