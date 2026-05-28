@tool
extends StaticBody2D

@export var crown_index: int:
	set(value):
		crown_index = clampi(value, 0, tree_crown.size() - 1)
		if is_node_ready():
			$Crown.texture = tree_crown[crown_index]
		
var tree_crown: = [
	preload("res://objects/tree/tree1.tres"),
	preload("res://objects/tree/tree2.tres")
	]

@onready var tween: Tween = create_tween().set_loops()

func _ready() -> void:
	randomize()
	crown_index = int(randi_range(0,tree_crown.size() - 1))
	start_swaying()

func start_swaying() -> void:
	tween.tween_property(self, "rotation_degrees", 2.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation_degrees", -2.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
