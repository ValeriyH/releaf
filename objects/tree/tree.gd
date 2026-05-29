@tool
extends StaticBody2D

@export var crown_index: int:
	set(value):
		crown_index = clampi(value, 0, tree_crown.size() - 1)
		if is_node_ready():
			$Crown.texture = tree_crown[crown_index]
		
var tree_crown: = [
	preload("res://objects/tree/res/tree1.tres"),
	preload("res://objects/tree/res/tree2.tres")
	]

@onready var burned_texture: = preload("res://objects/tree/res/burned.tres")
@onready var tween: Tween = create_tween().set_loops()

func _ready() -> void:
	randomize()
	crown_index = int(randi_range(0,tree_crown.size() - 1))
	start_swaying()
	Events.burn_command.connect(on_burn_command)
	

func start_swaying() -> void:
	tween.tween_property(self, "rotation_degrees", 2.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation_degrees", -2.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func on_burn_command(ctx: BurnContext) -> void:
	if (ctx.burn_node == self):
		set_collision_layer_value(Global.Layer.OBSTACLE, false)
		set_collision_layer_value(Global.Layer.FIREABLE, false)
		Events.burn_command.disconnect(on_burn_command)
		ctx.set_completed()
		
		#Burn effect
		$FireParticles.emitting = true
		tween.tween_property(self, "modulate", Color(0, 0, 0, 0), 0.8)
		await get_tree().create_timer(1.0).timeout
		$FireParticles.emitting = false
		tween.kill()
		
		#Post fire
		$Crown.hide()
		$Root.texture = burned_texture
		
