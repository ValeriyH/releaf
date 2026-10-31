extends Node

const INIT_SEEDS = 20
const INIT_ITEMS = 20

const MAX_HEALTH = 100.0
const MIN_HEALTH = 1.0 # No death yet: the player can't drop below this
const BURN_DAMAGE = 10.0 # Per second inside a fire
const MEDKIT_HEAL = 50.0
const MEDKIT_USE_AT = 30.0 # A medkit is used automatically at this health or below

const TANK_SPRAY_SECONDS = 20.0 # Full tank
const TANK_REFILL_SECONDS = 1.0

const STOCK_LIMITS = {
	Item.Type.Seed: 20,
	Item.Type.Refill: 5,
	Item.Type.Medkit: 3,
}
const STOCK_START = {
	Item.Type.Seed: 5,
	Item.Type.Refill: 1,
	Item.Type.Medkit: 1,
}

func get_world_rect() -> Rect2:
	return Rect2(-1600, -960, 3200, 1920)
