extends CharacterBody2D

@export var speed: int = 50
@export var move_destination: int = 300

const EventStatus := CommandContext.ExecutionStatus

enum State {MOVING, STANDING}

var state: State = State.STANDING
var direction: Vector2 = Vector2()

var destination: Vector2 = Vector2():
	set(value):
		destination.x = clamp(value.x, world_rect.position.x + 10, world_rect.end.x - 10)
		destination.y = clamp(value.y, world_rect.position.y + 10, world_rect.end.y - 10)	

var world_rect: Rect2 = Rect2(0, 0, 640, 480)
var burned_items: int = 0 #burned items since last check. If no burned items fire will starve

func _ready() -> void:
	world_rect = Settings.get_world_rect()
	Events.burn_processed.connect(on_burn_processed)
	move()

func _process(delta: float) -> void:
	if state == State.MOVING:
		var collision:  = move_and_collide(direction * delta)
		if collision:
			# collide with unfirebla object like stone/water
			# so we "reach" destinateion
			destination = position
		if position.distance_to(destination) < speed:
			stop()
		
		position.x = clamp(position.x, world_rect.position.x + 5, world_rect.end.x - 5)
		position.y = clamp(position.y, world_rect.position.y + 5, world_rect.end.y - 5)

func move() -> void:
	if state == State.STANDING:
		select_destination()
		state = State.MOVING

func stop() -> void:
	state = State.STANDING
	$MoveTimer.start(2)

func select_destination() -> void:
	randomize()
	
	var new_destination: Vector2
	for i in range(5):
		new_destination = Vector2(
			randf_range(position.x - move_destination, position.x + move_destination),
			randf_range(position.y - move_destination, position.y + move_destination)
		)
		if world_rect.has_point(new_destination): break
	
	#if new_destination is out of world area it will corrected durng set property
	destination = new_destination
	direction = (destination - position).normalized() * speed

func _on_Timer_timeout() -> void:
	move()

func _on_HungryTimer_timeout() -> void:
	if burned_items == 0:
		print(name, " starving")
		scale.x -= 0.1
		scale.y -= 0.1
		if scale.x < 1:
			scale.x = 1
			scale.y = 1
	burned_items = 0

func _on_Audio_finished() -> void:
	$Audio.play()
	
func _on_hitbox_area_entered(node: Node2D) -> void:
	#print("area " + node.name)
	var ctx: = BurnContext.new(self, node)
	Events.burn_command.emit(ctx)

func on_burn_processed(ctx: BurnContext) -> void:
	if ctx.initiator == self and ctx.status == EventStatus.SUCCESS:
		$Burn.play()
		#fire grow
		scale.x += 0.1
		scale.y += 0.1
		burned_items += 1
		destination = destination + direction * 3
		print(name, " burn ", ctx.burn_node.name,
			 ". Current burned items ", burned_items)
