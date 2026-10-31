class_name PlayerTool
extends RefCounted
## Tools are always with the player and are selected in the HUD, unlike items
## (see Item), which are collected into a stock and used up automatically.

enum Type {
	Shovel,
	Extinguisher
}

const TEXTURES: = {
	Type.Shovel: preload("res://objects/player/res/shovel.png"),
	Type.Extinguisher: preload("res://objects/item/res/extinguisher_v2.png"),
}
