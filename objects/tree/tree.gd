extends StaticBody2D

@export var tree_crown = [
	preload("res://objects/tree/tree1.tres"),
	preload("res://objects/tree/tree2.tres")
	]

@onready var tween: Tween = create_tween().set_loops()

func _ready() -> void:
	randomize()
	var i = int(randi_range(0,tree_crown.size() - 1))
	$Crown.texture = tree_crown[i]
	start_swaying()

func start_swaying():
	tween.tween_property(self, "rotation_degrees", 2.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation_degrees", -2.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
