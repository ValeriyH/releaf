@tool
extends Area2D
class_name Item

enum Type {
	Seed,
	Heart,
	IceCream,
	Extinguisher
}

const TEXTURES: = {
	Type.Seed: preload("res://objects/item/res/seed.png"),
	Type.Heart: preload("res://objects/item/res/heart.png"),
	Type.IceCream: preload("res://objects/item/res/icecream.png"),
	Type.Extinguisher: preload("res://objects/item/res/extinguisher.png"),
}

@export var item: = Type.Seed:
	set(value):
		if is_node_ready():
			$Sprite.texture = TEXTURES[value]
			item = value
			name = str(Type.keys()[item])

func _ready() -> void:
	Events.burn_command.connect(on_burn_command)

func on_burn_command(ctx: BurnContext) -> void:
	if ctx.burn_node == self:
		ctx.set_completed()
		var destroy: = ItemDestroyContext.new(self, self, ItemDestroyContext.DestroyReason.BURNED)
		Events.item_destroy_command.emit(destroy)
