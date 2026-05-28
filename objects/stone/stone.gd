@tool
extends StaticBody2D

@export var stone_index: int = 0:
	set(value):
		stone_index = clampi(value, 0, stones.size() - 1)
		if is_node_ready():
			$Sprite2D.texture = stones[stone_index]
	
var stones = [
	preload("res://objects/stone/stone1.tres"),
	preload("res://objects/stone/stone2.tres")
	]

func _ready() -> void:
	var index = randi_range(0, stones.size() -1)
	stone_index = index
