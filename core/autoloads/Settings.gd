extends Node

const BURN_DAMAGE = 10.0 # Per second inside a fire
const MEDKIT_HEAL = 50.0
const MEDKIT_USE_AT = 30.0 # A medkit is used automatically at this health or below

const TANK_REFILL_SECONDS = 1.0
const TANK_WATER_REFILL_SECONDS = 3.0 # Full tank, standing on water

const TREE_SAPLING_SCALE = 0.25

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

# Changed on the settings screen and saved between runs. "key" is the variable below.
const TUNABLES = [
	{"key": "trees_to_win", "label": "TREES TO WIN", "min": 10.0, "max": 300.0, "step": 10.0, "default": 100.0},
	{"key": "max_health", "label": "HEALTH", "min": 50.0, "max": 300.0, "step": 25.0, "default": 100.0},
	{"key": "tank_spray_seconds", "label": "TANK SECONDS", "min": 5.0, "max": 60.0, "step": 5.0, "default": 20.0},
	{"key": "tree_grow_seconds", "label": "TREE GROWTH SEC", "min": 10.0, "max": 300.0, "step": 10.0, "default": 60.0},
	{"key": "tree_fruit_seconds_min", "label": "SEED DROP MIN SEC", "min": 10.0, "max": 300.0, "step": 10.0, "default": 60.0},
	{"key": "tree_fruit_seconds_max", "label": "SEED DROP MAX SEC", "min": 10.0, "max": 300.0, "step": 10.0, "default": 90.0},
	{"key": "fire_count", "label": "FIRES", "min": 1.0, "max": 20.0, "step": 1.0, "default": 5.0},
	{"key": "items_at_start", "label": "ITEMS AT START", "min": 0.0, "max": 100.0, "step": 10.0, "default": 40.0},
]
const SAVE_PATH = "user://settings.cfg"
const SAVE_SECTION = "gameplay"

var trees_to_win: float # Grown trees standing at the same time
var max_health: float
var tank_spray_seconds: float # Full tank
var tree_grow_seconds: float
var tree_fruit_seconds_min: float
var tree_fruit_seconds_max: float
var fire_count: float
var items_at_start: float # Half are seeds, the rest of a random type


func _init() -> void:
	var config: = ConfigFile.new()
	config.load(SAVE_PATH) # A missing or broken file leaves the defaults below
	for spec: Dictionary in TUNABLES:
		var saved: Variant = config.get_value(SAVE_SECTION, spec.key, spec.default)
		set(spec.key, clamp_to_spec(spec, float(saved) if saved is float or saved is int else spec.default))
	keep_fruit_range(&"tree_fruit_seconds_min")


func set_tunable(spec: Dictionary, value: float) -> void:
	set(spec.key, clamp_to_spec(spec, value))
	keep_fruit_range(spec.key)
	save()


func reset_tunables() -> void:
	for spec: Dictionary in TUNABLES:
		set(spec.key, spec.default)
	save()


func clamp_to_spec(spec: Dictionary, value: float) -> float:
	return clampf(snappedf(value, spec.step), spec.min, spec.max)


# The value just changed wins, the other end of the range follows it
func keep_fruit_range(changed: StringName) -> void:
	if tree_fruit_seconds_min > tree_fruit_seconds_max:
		if changed == &"tree_fruit_seconds_max":
			tree_fruit_seconds_min = tree_fruit_seconds_max
		else:
			tree_fruit_seconds_max = tree_fruit_seconds_min


func save() -> void:
	var config: = ConfigFile.new()
	for spec: Dictionary in TUNABLES:
		config.set_value(SAVE_SECTION, spec.key, get(spec.key))
	config.save(SAVE_PATH)


func get_world_rect() -> Rect2:
	return Rect2(-1600, -960, 3200, 1920)
