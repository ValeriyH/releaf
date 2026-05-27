extends CharacterBody2D

#@onready var main  = Global.get_main()
@export var speed: int = 50
@export var move_destination: int = 300

enum State {MOVING, STANDING}

var state: State = State.STANDING
var direction: Vector2 = Vector2()
var destination: Vector2 = Vector2()
var world_rect: Rect2 = Rect2(0, 0, 640, 480)
var burned_items: int = 0 #burned items since last check. If no burned items fire will starve

func _ready():
	world_rect = Global.get_world_rect()
	move()

func _process(delta):
	if state == State.MOVING:
		var collision  = move_and_collide(direction * delta)
		if collision:
			if collision.get_collider().has_method("burn"):
				# Burn found object
				collision.collider.call("burn", self)
				$Burn.play()
				#fire grow
				scale.x += 0.1
				scale.y += 0.1
				burned_items += 1
				# Continue move in the same direction
				# If fire move to direction and "found food" 
				# it will try to increase this direction vector for 3 seconds
				destination = destination + direction * 3
				print(name, " burn ", collision.collider.name, ". Current burned items ", burned_items)
			else:
				# collide with unfirebla object like stone/water
				# so we "reach" destinateion
				destination = position
		if position.distance_to(destination) < speed:
			stop()
		
		position.x = clamp(position.x, world_rect.position.x + 5, world_rect.end.x - 5)
		position.y = clamp(position.y, world_rect.position.y + 5, world_rect.end.y - 5)

func _player_collision(player):
	player.burn(self)

func move():
	if state == State.STANDING:
		select_destination()
		state = State.MOVING

func stop():
	state = State.STANDING
	$MoveTimer.start(2)

func select_destination():
	randomize()
	var x = randf_range(position.x - move_destination, position.x + move_destination)
	var y = randf_range(position.y - move_destination, position.y + move_destination)
	x = clamp(x, world_rect.position.x + 10, world_rect.end.x - 10)
	y = clamp(y, world_rect.position.y + 10, world_rect.end.y - 10)	
	destination = Vector2(x, y)
	direction = (destination - position).normalized() * speed

func _on_Timer_timeout():
	move()

func _on_HungryTimer_timeout():
	if burned_items == 0:
		print(name, " starving")
		scale.x -= 0.1
		scale.y -= 0.1
		if scale.x < 1:
			scale.x = 1
			scale.y = 1
	burned_items = 0


func _on_Audio_finished():
	$Audio.play()
