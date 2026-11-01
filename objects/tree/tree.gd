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

const SEED_DROP_DISTANCE: = Vector2(30.0, 70.0)
const SEED_DROP_WORLD_MARGIN: = 32.0 # Stays reachable, inside the world walls

@onready var burned_texture: = preload("res://objects/tree/res/burned.tres")
@onready var tween: Tween = create_tween().set_loops()

var grown: = true # Trees placed in the world are grown, the planted ones are set to false
var grow_tween: Tween

func _ready() -> void:
	randomize()
	crown_index = int(randi_range(0,tree_crown.size() - 1))
	start_swaying()
	if Engine.is_editor_hint():
		return
	Events.burn_command.connect(on_burn_command)
	add_to_group(Global.LIVING_TREES_GROUP)
	if grown:
		add_to_group(Global.GROWN_TREES_GROUP)
		start_fruit_timer()
	else:
		grow()

func grow() -> void:
	scale = Vector2.ONE * Settings.TREE_SAPLING_SCALE
	grow_tween = create_tween()
	grow_tween.tween_property(self, "scale", Vector2.ONE, Settings.tree_grow_seconds)
	grow_tween.finished.connect(on_grown)

func on_grown() -> void:
	grown = true
	add_to_group(Global.GROWN_TREES_GROUP)
	start_fruit_timer()
	Events.tree_grown.emit()

func start_fruit_timer() -> void:
	$FruitTimer.start(randf_range(Settings.tree_fruit_seconds_min, Settings.tree_fruit_seconds_max))

# Seeds drop in front of the tree: the crown would hide them behind it
func on_fruit_timer_timeout() -> void:
	var offset: = Vector2.from_angle(randf_range(0.0, PI)) * randf_range(SEED_DROP_DISTANCE.x, SEED_DROP_DISTANCE.y)
	var area: = Settings.get_world_rect().grow(-SEED_DROP_WORLD_MARGIN)
	var pos: = (global_position + offset).clamp(area.position, area.end)
	ItemSpawnCommand.new(self, Item.Type.Seed, pos).send()
	start_fruit_timer()

func start_swaying() -> void:
	tween.tween_property(self, "rotation_degrees", 2.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation_degrees", -2.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func on_burn_command(cmd: BurnCommand) -> void:
	if (cmd.burn_node == self):
		set_collision_layer_value(Global.Layer.OBSTACLE, false)
		set_collision_layer_value(Global.Layer.FIREABLE, false)
		Events.burn_command.disconnect(on_burn_command)
		remove_from_group(Global.GROWN_TREES_GROUP)
		remove_from_group(Global.LIVING_TREES_GROUP)
		$FruitTimer.stop()
		if grow_tween:
			grow_tween.kill()
		cmd.set_completed()
		
		#Burn effect
		$FireParticles.emitting = true
		tween.tween_property(self, "modulate", Color(0, 0, 0, 0), 0.8)
		await get_tree().create_timer(1.0).timeout
		$FireParticles.emitting = false
		tween.kill()
		
		#Post fire
		$Crown.hide()
		$Root.texture = burned_texture
		
