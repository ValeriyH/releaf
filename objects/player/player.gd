extends CharacterBody2D
class_name Player

const TURN_THRESHOLD: = 0.15

var base_speed: = 200
var direction: Vector2 = Vector2()
var selected_tool: PlayerTool.Type = PlayerTool.Type.Extinguisher:
	set(value):
		selected_tool = value
		$Direction/ActionBox/Sprite2D.texture = PlayerTool.TEXTURES[value]

var health: float = Settings.MAX_HEALTH
var tank: = 1.0 # Extinguisher charge, 0..1
var refilling: = false
var stock: Dictionary = Settings.STOCK_START.duplicate()

var fire_tween: Tween

func _ready() -> void:
	Events.burn_command.connect(on_burn)
	Events.pick_item_processed.connect(on_pick_item)
	Events.plant_tree_processed.connect(on_plant_tree)
	Events.select_tool_command.connect(on_select_tool)
	Events.use_item_command.connect(on_use_item)

func _input(event: InputEvent) -> void:
	var key_event: = event as InputEventKey
	if key_event and key_event.pressed and not key_event.echo:
		match key_event.keycode:
			KEY_1:
				SelectToolCommand.new(self, PlayerTool.Type.Shovel).send()
			KEY_2:
				SelectToolCommand.new(self, PlayerTool.Type.Extinguisher).send()

	if selected_tool == PlayerTool.Type.Shovel and event.is_action_pressed("ui_accept") and can_act():
		var pos: Vector2 = $Direction/ActionBox/Sprite2D.global_position
		var plant: = PlantTreeCommand.new(self, pos)
		plant.send()


## True if the selected tool can do its job right now
func can_act() -> bool:
	match selected_tool:
		PlayerTool.Type.Shovel:
			return stock[Item.Type.Seed] > 0
		PlayerTool.Type.Extinguisher:
			return tank > 0.0 and not refilling
	return false


# Input is polled: the virtual joystick changes action state without sending input events
func _physics_process(delta: float) -> void:
	var spraying: = selected_tool == PlayerTool.Type.Extinguisher and can_act() and Input.is_action_pressed("ui_accept")
	$Direction/HitBox.visible = spraying
	$Direction/HitBox.monitoring = spraying
	update_tank(spraying, delta)

	direction = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).limit_length()

	if direction.is_zero_approx():
		$Sprite.pause()
	else:
		if (!$Sprite.is_playing()):
			$Sprite.play("move")
		$Sprite.speed_scale = direction.length()
		# Ignore a slight sideways tilt so walking up or down doesn't flip the sprite
		if absf(direction.x) > TURN_THRESHOLD:
			$Sprite.flip_h = direction.x < 0
			$Direction.scale.x = abs($Direction.scale.x) * sign(direction.x)

	velocity = direction * base_speed
	move_and_slide()

func update_tank(spraying: bool, delta: float) -> void:
	if refilling:
		tank = move_toward(tank, 1.0, delta / Settings.TANK_REFILL_SECONDS)
		refilling = tank < 1.0
		Events.player_state_changed.emit(self)
	elif spraying:
		tank = move_toward(tank, 0.0, delta / Settings.TANK_SPRAY_SECONDS)
		Events.player_state_changed.emit(self)
		use_supplies()

## Items work on their own: whatever is in stock and needed right now gets used
func use_supplies() -> void:
	if tank <= 0.0 and not refilling and stock[Item.Type.Refill] > 0:
		UseItemCommand.new(self, Item.Type.Refill).send()
	if health <= Settings.MEDKIT_USE_AT and stock[Item.Type.Medkit] > 0:
		UseItemCommand.new(self, Item.Type.Medkit).send()

func on_use_item(cmd: UseItemCommand) -> void:
	if cmd.initiator != self:
		return
	stock[cmd.item_type] -= 1
	match cmd.item_type:
		Item.Type.Refill:
			refilling = true
		Item.Type.Medkit:
			health = minf(health + Settings.MEDKIT_HEAL, Settings.MAX_HEALTH)
	cmd.set_completed()
	Events.player_state_changed.emit(self)
	pick_items_in_reach.call_deferred()

func can_pick(item: Item) -> bool:
	return not item.is_queued_for_deletion() and stock[item.item] < Settings.STOCK_LIMITS[item.item]

## Items stay on the ground while their stock is full
func on_action_box_body_entered(node: Node2D) -> void:
	print("Player area " + node.name)
	var item: = node as Item
	if item and can_pick(item):
		var cmd: = PickItemCommand.new(self, item)
		cmd.send()

# Entered signals don't repeat, so an item left behind by a full stock is checked again.
# Call deferred: an item being picked up right now is removed only after its command ends.
func pick_items_in_reach() -> void:
	for area in $Direction/ActionBox.get_overlapping_areas():
		on_action_box_body_entered(area)

func on_pick_item(cmd: PickItemCommand) -> void:
	if cmd.initiator == self:
		print("Picked item " + cmd.item.name)
		stock[cmd.item.item] += 1
		Events.player_state_changed.emit(self)
		use_supplies()

func on_burn(cmd: BurnCommand) -> void:
	if cmd.burn_node == self:
		print("Player at fire!!!")
		cmd.set_completed()
		burn_while_inside(cmd.initiator)

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

func burn_while_inside(fire: Node) -> void:
	while is_instance_valid(fire) and fire.get_node("Hitbox").get_overlapping_bodies().has(self):
		health = maxf(health - Settings.BURN_DAMAGE, Settings.MIN_HEALTH)
		Events.player_state_changed.emit(self)
		use_supplies()
		await get_tree().create_timer(1, false).timeout

func on_plant_tree(cmd: PlantTreeCommand) -> void:
	if cmd.initiator == self and cmd.status == cmd.ExecutionStatus.SUCCESS:
		print("Player plant tree")
		stock[Item.Type.Seed] -= 1
		Events.player_state_changed.emit(self)
		pick_items_in_reach.call_deferred()

func on_select_tool(cmd: SelectToolCommand) -> void:
	selected_tool = cmd.tool_type
	cmd.set_completed()
	Events.player_state_changed.emit(self)


func on_hit_box_body_entered(body: Node2D) -> void:
	print("Fire enter hitbox " + body.name)
	var hit: = true
	while hit:
		print("Attack fire " + body.name)
		#send command
		FireQuenchCommand.new(self, body).send()
		await get_tree().create_timer(1, false).timeout
		hit = $Direction/HitBox.monitoring and $Direction/HitBox.get_overlapping_bodies().has(body)

func on_hit_box_body_exited(body: Node2D) -> void:
	print("Fire exit hitbox " + body.name)
	pass # Replace with function body.
