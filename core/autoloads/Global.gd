extends Node

const GROWN_TREES_GROUP: = &"grown_trees"
const LIVING_TREES_GROUP: = &"living_trees" # Grown trees and saplings

enum LoseReason {
	PLAYER_BURNED, # Also the index of its message on the lose screen
	FOREST_BURNED
}

enum Layer {
	OBSTACLE = 1, #stones, water, etc. Can't be burn
	FIREABLE = 2, #items, trees, user and other object what can be burn
	ITEM = 3, #consumable and pickable items
	TREE = 4,
	STONE = 5,
	WATER = 6
}

enum LayerMask {
	OBSTACLE = 0b1,
	FIREABLE = 0b10,
	ITEM = 0b100,
	FIRE = 0b1000,
	OLD_STONE = 0b10000,
	OLD_WATER = 0b100000
}

func _ready() -> void:
	pass
