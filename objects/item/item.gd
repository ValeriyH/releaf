@tool
extends Area2D
class_name Item

enum Type {
	Seed,
	Refill,
	Medkit
}

const TEXTURES: = {
	Type.Seed: preload("res://objects/item/res/seed.png"),
	Type.Refill: preload("res://objects/item/res/refill.png"),
	Type.Medkit: preload("res://objects/item/res/medkit.png"),
}

@export var item: = Type.Seed:
	set(value):
		if is_node_ready():
			$Sprite.texture = TEXTURES[value]
			item = value
			name = str(Type.keys()[item])

func _ready() -> void:
	Events.burn_command.connect(on_burn_command)
	Events.pick_item_command.connect(on_pick_command)

func on_burn_command(ctx: BurnCommand) -> void:
	if ctx.burn_node == self:
		ctx.set_completed()
		var destroy_command: = ItemDestroyCommand.new(self, self, ItemDestroyCommand.DestroyReason.BURNED)
		destroy_command.send()
		
func on_pick_command(ctx: PickItemCommand) -> void:
	if ctx.item == self:
		ctx.set_completed()
		var destroy_command: = ItemDestroyCommand.new(self, self, ItemDestroyCommand.DestroyReason.PICKED_UP)
		destroy_command.send()
	
