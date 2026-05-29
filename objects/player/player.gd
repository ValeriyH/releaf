extends CharacterBody2D
class_name Player

var base_speed: = 200
var direction: Vector2 = Vector2()

func _input(event: InputEvent) -> void:
	if (event is not InputEventKey):
		return
	
	direction = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	
	if (direction.x == 0 and direction.y == 0):
		$Sprite.pause()
	else:
		if (!$Sprite.is_playing()):
			$Sprite.play("move")
		$Sprite.flip_h = direction.x < 0
		direction = direction.normalized() * base_speed

func _process(delta: float) -> void:
	move_and_collide(direction * delta)

func on_action_box_body_entered(_body: Node2D) -> void:
	#print("Player area " + body.name)
	pass
