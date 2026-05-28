@tool
extends Area2D

const TEXTURES: = {
	Global.Items.Seed: preload("res://objects/item/img/seed.png"),
	Global.Items.Heart: preload("res://objects/item/img/heart.png"),
	Global.Items.IceCream: preload("res://objects/item/img/icecream.png"),
	Global.Items.Extinguisher: preload("res://objects/item/img/extinguisher.png"),
}

@export var item: Global.Items = Global.Items.Seed:
	set(value):
		if is_node_ready():
			$Sprite.texture = TEXTURES[value]
			item = value

func _ready() -> void:
	pass
