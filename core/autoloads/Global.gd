extends Node

enum LayerBit {
	OBJECT = 0,
	FIREABLE = 1,
	TREE = 2,
	ITEM = 3,
	STONE = 4,
	WATER = 5
}

enum Layers {
	OBJECT = 0b1,
	FIREABLE = 0b10,
	TREE = 0b100,
	ITEM = 0b1000,
	STONE = 0b10000,
	WATER = 0b100000
}

enum Items {
	Seed,
	Heart,
	IceCream,
	Extinguisher
}

func _ready():
	pass
