# Releaf — Project Overview

A 2D top-down Godot 4 game where the player manages a forest: planting trees, extinguishing fires, and collecting items.

> **Note**: `AGENTS.md` auto-loads at session start and instructs the agent to read this file.

## Tech Stack

- **Engine**: Godot 4.6 (GL Compatibility, D3D12)
- **Language**: GDScript
- **Physics**: Jolt Physics (2D)
- **Resolution**: 1280x720, stretch mode `canvas_items`

## Directory Structure

```
releaf/
├── core/
│   ├── main.tscn              # Main scene (World + HUD)
│   ├── world.tscn             # World scene (player, enemies, nature, items, background)
│   ├── world.gd               # World script (item spawning, tree planting)
│   ├── background.gd          # Procedural background generator (grass, roads, flowers)
│   ├── boundary.gd            # World boundary (collision walls + dark gradient)
│   ├── autoloads/
│   │   ├── Global.gd          # Layer enums (OBSTACLE, FIREABLE, ITEM, FIRE, etc.)
│   │   ├── Events.gd          # Global signal bus for commands
│   │   └── Settings.gd        # World constants (INIT_SEEDS=20, INIT_ITEMS=20, world rect)
│   └── commands/
│       ├── Command.gd         # Abstract base command (initiator, status, send/set_completed)
│       ├── BurnCommand.gd     # Fire burns a node
│       ├── FireQuenchCommand.gd # Player extinguishes fire
│       ├── ItemSpawnCommand.gd  # Spawn item at position
│       ├── ItemDestroyCommand.gd # Destroy item (PICKED_UP, BURNED, DECAYED)
│       ├── PickItemCommand.gd   # Player picks up item
│       ├── PlantTreeCommand.gd  # Player plants a tree
│       └── SelectItemCommand.gd # Switch active item
├── objects/
│   ├── player/
│   │   ├── player.gd          # CharacterBody2D, WASD movement, item interaction
│   │   └── player.tscn        # Camera2D (zoom 2x), AnimatedSprite2D, ActionBox, HitBox
│   ├── tree/
│   │   ├── tree.gd            # StaticBody2D, sway animation, burn logic
│   │   └── tree.tscn          # Crown + Root sprites, FireParticles
│   ├── stone/
│   │   ├── stone.gd           # StaticBody2D, random stone variant
│   │   └── stone.tscn
│   ├── fire/
│   │   ├── fire.gd            # CharacterBody2D, AI movement, burns items/trees
│   │   └── fire.tscn          # AnimatedSprite2D, Hitbox, BurnRadius, timers
│   └── item/
│       ├── item.gd            # Area2D, types: Seed, Heart, IceCream, Extinguisher
│       └── item.tscn
├── ui/
│   ├── hud/
│   │   ├── ui.gd              # HUD script (seed/extinguisher buttons)
│   │   └── UI.tscn            # CanvasLayer, TouchScreenJoystick, action buttons
│   └── main_menu/             # Empty (not implemented)
├── addons/
│   └── touch_screen_joystick/ # Virtual joystick for mobile
└── assets/
    ├── atlas/                 # Texture atlases
    ├── audio/                 # Sound effects
    └── fonts/                 # Fonts
```

## Autoloads (Singletons)

| Autoload | Path | Purpose |
|----------|------|---------|
| `Global` | `core/autoloads/Global.gd` | Layer enums (`OBSTACLE`, `FIREABLE`, `ITEM`, `FIRE`, `TREE`, `STONE`, `WATER`) and layer masks |
| `Events` | `core/autoloads/Events.gd` | Global signal bus — all command signals (spawn, destroy, pick, plant, burn, quench, select) |
| `Settings` | `core/autoloads/Settings.gd` | World constants: `INIT_SEEDS=20`, `INIT_ITEMS=20`, `get_world_rect()` returns `Rect2(-1600, -960, 3200, 1920)` |

## Command System

All game actions go through a **command pattern**:

1. Create a command: `var cmd := BurnCommand.new(self, target_node)`
2. Send it: `cmd.send()` — this emits the signal on `Events`
3. The relevant object handles it and calls `cmd.set_completed(status)`
4. The result is automatically emitted on the corresponding `*_processed` signal

### Commands

| Command | Signal Emitted | Handled By |
|---------|---------------|------------|
| `BurnCommand` | `burn_command` | Trees, Items, Player |
| `FireQuenchCommand` | `fire_quench_command` | Fire |
| `ItemSpawnCommand` | `item_spawn_command` | World |
| `ItemDestroyCommand` | `item_destroy_command` | World |
| `PickItemCommand` | `pick_item_command` | World |
| `PlantTreeCommand` | `plant_tree_command` | World |
| `SelectItemCommand` | `select_item_command` | Player |

## Physics Layers

| Layer | Bit | Used By |
|-------|-----|---------|
| `OBSTACLE` | 1 | Stones (can't be burned) |
| `FIREABLE` | 2 | Items, trees, player (can be burned) |
| `ITEM` | 3 | Pickable items |
| `FIRE` | 4 | Fire objects |
| `TREE` | 5 | (reserved) |
| `STONE` | 6 | (reserved) |
| `WATER` | 7 | (reserved) |

## Input Map

| Action | Keys | Joypad |
|--------|------|--------|
| `ui_left` | A / Left | D-pad left, Left stick X- |
| `ui_right` | D / Right | D-pad right, Left stick X+ |
| `ui_up` | W / Up | D-pad up, Left stick Y- |
| `ui_down` | S / Down | D-pad down, Left stick Y+ |
| `ui_accept` | Enter / Space | Button 0 (A) |

## Player Mechanics

- **Movement**: WASD/arrows, speed 200 px/s
- **Items**: Press `1` for Seed, `2` for Extinguisher
- **Plant tree**: Select Seed + press `ui_accept` (Enter/Space)
- **Extinguish fire**: Select Extinguisher + hold `ui_accept` near fire
- **Pick up items**: Walk into items with ActionBox (Area2D)
- **Camera**: Camera2D with 2x zoom, follows player

## World Generation

- **Background**: Procedurally generated at startup by `core/background.gd`
  - 12 tile types: 4 grass variants, road, road edge, 4 flowers, 2 grass tufts
  - 32x32 pixel tiles, world is 100x60 tiles (3200x1920)
  - Horizontal road, vertical road, winding path
  - Random flowers (~3%) and grass tufts (~5%)
- **Boundary**: `core/boundary.gd` provides collision walls and dark gradient
  - 4 `StaticBody2D` walls (40px thick) on OBSTACLE layer block player and fires
  - Dark gradient texture (512x512) with noise for smoky effect
  - `OutsideDarkness` sprite covers area outside world rect
  - Gradient extends 600px beyond world edges
- **Initial items**: 20 seeds + 20 random items spawned at random positions
- **Trees**: 8 trees placed in world.tscn
- **Stones**: 9 stones placed in world.tscn
- **Fires**: 5 fires placed in world.tscn

## Fire AI

- Fires are `CharacterBody2D` that roam randomly
- They have a `BurnRadius` (Area2D) that detects fireable objects
- On contact, they send `BurnCommand` to burn trees/items/player
- Fires grow (+0.1 scale) when they burn something
- Fires shrink (-0.1 scale) when extinguished by player
- If no burns for 300s, fire "starves" and shrinks

## Item Types

| Type | Texture | Purpose |
|------|---------|---------|
| `Seed` | `seed.png` | Plant trees |
| `Heart` | `heart.png` | (not yet implemented) |
| `IceCream` | `icecream.png` | (not yet implemented) |
| `Extinguisher` | `extinguisher.png` | Extinguish fires |

## UI/HUD

- `CanvasLayer` with touch controls
- `TouchScreenJoystick` (left side) for movement
- `ActionButton` (right side) for context action
- Seed and Extinguisher buttons to switch active item
