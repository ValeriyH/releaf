extends CharacterBody2D
class_name Player

var base_speed: = 200
var direction: Vector2 = Vector2()
var selected_item: Item.Type = Item.Type.Extinguisher:
	set(value):
		selected_item = value
		$Direction/ActionBox/Sprite2D.texture = Item.TEXTURES[value]

var fire_tween: Tween

func _ready() -> void:
	Events.burn_command.connect(on_burn)
	Events.pick_item_processed.connect(on_pick_item)
	Events.plant_tree_processed.connect(on_plant_tree)
	Events.select_item_command.connect(on_select_item)

func _input(event: InputEvent) -> void:
	#if (event is not InputEventKey):
	#	return
		
	#Temporary: Use SelectItemCommand to switch between items in inventory
	var key_event: = event as InputEventKey
	if key_event:
		match key_event.keycode:
			KEY_1:
				selected_item = Item.Type.Seed
			KEY_2:
				selected_item = Item.Type.Extinguisher
	
	direction = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	
	if selected_item == Item.Type.Seed and event.is_action_pressed("ui_accept"):
		var pos: Vector2 = $Direction/ActionBox/Sprite2D.global_position
		var plant: = PlantTreeCommand.new(self, pos)
		plant.send()

	if selected_item == Item.Type.Extinguisher:
		if Input.is_action_pressed("ui_accept"):
			$Direction/HitBox.visible = true
			$Direction/HitBox.monitoring = true
		else:
			$Direction/HitBox.visible = false
			$Direction/HitBox.monitoring = false

	if (direction.x == 0 and direction.y == 0):
		$Sprite.pause()
	else:
		if (!$Sprite.is_playing()):
			$Sprite.play("move")
		$Sprite.flip_h = direction.x < 0
		direction = direction.normalized() * base_speed
		if direction.x != 0:
			$Direction.scale.x = abs($Direction.scale.x) * sign(direction.x)
			

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
		#update inventory

func on_burn(cmd: BurnCommand) -> void:
	if cmd.burn_node == self:
		print("Player at fire!!!")
		cmd.set_completed()
		
		#burn animation
		if fire_tween and fire_tween.is_valid():
			return
		fire_tween = create_tween().set_loops(5)

		# Step 1: Tint red and shrink slightly (squish)
		fire_tween.tween_property(self, "modulate", Color(1.0, 0.3, 0.3), 0.2)
		fire_tween.parallel().tween_property(self, "scale", Vector2(0.9, 0.9), 0.2)

		# Step 2: Return to normal (chaining steps in parallel tweens requires a interval offset)
		fire_tween.tween_property(self, "modulate", Color.WHITE, 0.2)
		fire_tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.2)

func on_plant_tree(cmd: PlantTreeCommand) -> void:
	if cmd.initiator == self and cmd.status == cmd.ExecutionStatus.SUCCESS:
		print("Player plant tree")
		
func on_select_item(cmd: SelectItemCommand) -> void:
	selected_item = cmd.item
	cmd.set_completed()
	
	
func on_hit_box_body_entered(body: Node2D) -> void:
	print("Fire enter hitbox " + body.name)
	var hit: = true
	while hit:
		print("Attack fire " + body.name)
		#send command
		FireQuenchCommand.new(self, body).send()
		await get_tree().create_timer(1, false).timeout
		hit = $Direction/HitBox.get_overlapping_bodies().has(body)

func on_hit_box_body_exited(body: Node2D) -> void:
	print("Fire exit hitbox " + body.name)
	pass # Replace with function body.
