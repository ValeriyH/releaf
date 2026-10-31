# Releaf — Project Overview

A 2D top-down Godot 4 game where the player manages a forest: planting trees, extinguishing fires, and collecting supplies before the fire burns them.

> **Note**: [AGENTS.md](AGENTS.md) auto-loads at session start and instructs the agent to read this file.

## Tech Stack

- **Engine**: Godot 4.6 (GL Compatibility, D3D12)
- **Language**: GDScript
- **Physics**: Godot 2D physics
- **Resolution**: 1280x720, stretch mode `canvas_items`, aspect `expand` (wide and tall screens see more of the world, no black bars)
- **Orientation on handhelds**: sensor landscape
- **Running Godot from the terminal**: use the `GODOT` environment variable (points to the console executable, e.g. `& $env:GODOT --headless --path . --check-only`).

## Web / PWA

- Export preset `Web` in `export_presets.cfg`: PWA enabled, standalone, landscape, no threads (no special server headers needed)
- Local export: `mkdir build; & $env:GODOT --headless --path . --export-release Web build/index.html` (`build/` is git-ignored, the folder must exist)
- Deploy: `.github/workflows/main.yml` exports `Web` and publishes to GitHub Pages on push to `main`

## Development with Claude Code

Parts of this project are developed with [Claude Code](https://claude.com/claude-code). To see what came from it:

- Commits made by an AI agent have the `[AI]` prefix in the subject
- Pull request descriptions created by Claude Code end with a `Generated with Claude Code` line
- Commits don't carry a `Co-Authored-By` line (`attribution.commit` is empty in the Claude Code settings)

## Directory Structure

```
releaf/
├── core/
│   ├── main.tscn              # Main scene (World + HUD)
│   ├── world.tscn             # World scene (player, enemies, nature, items, background)
│   ├── world.gd               # World script (item spawning, tree planting, WorldBoundary set)
│   ├── background.gd          # Background generator (terrain autotiling: grass, roads, pond, decor)
│   ├── world.gdshader         # World boundary fade shaper
│   ├── autoloads/
│   │   ├── Global.gd          # Layer enums (OBSTACLE, FIREABLE, ITEM, FIRE, etc.)
│   │   ├── Events.gd          # Global signal bus for commands
│   │   └── Settings.gd        # World and balance constants (item counts, health, tank, stock limits)
│   └── commands/
│       ├── Command.gd         # Abstract base command (initiator, status, send/set_completed)
│       ├── BurnCommand.gd     # Fire burns a node
│       ├── FireQuenchCommand.gd # Player extinguishes fire
│       ├── ItemSpawnCommand.gd  # Spawn item at position
│       ├── ItemDestroyCommand.gd # Destroy item (PICKED_UP, BURNED, DECAYED)
│       ├── PickItemCommand.gd   # Player picks up item
│       ├── PlantTreeCommand.gd  # Player plants a tree
│       ├── SelectToolCommand.gd # Switch active tool
│       └── UseItemCommand.gd  # Spend an item from stock (sent automatically by the player)
├── objects/
│   ├── player/
│   │   ├── player.gd          # CharacterBody2D, polled analog movement, tools, health, tank, item stock
│   │   ├── player_tool.gd     # PlayerTool: tool types (Shovel, Extinguisher) and textures
│   │   ├── res/               # shovel.png
│   │   ├── player.tscn        # Camera2D (zoom 2x), AnimatedSprite2D, ActionBox, HitBox
│   │   └── player.png         # Player sprite sheet
│   ├── tree/
│   │   ├── tree.gd            # StaticBody2D, sway animation, burn logic
│   │   ├── tree.tscn          # Crown + Root sprites, FireParticles
│   │   └── res/               # AtlasTexture resources: tree1/2, root, burned (.tres)
│   ├── stone/
│   │   ├── stone.gd           # StaticBody2D, random stone variant
│   │   ├── stone.tscn
│   │   └── stone1/2.tres      # AtlasTexture resources for stone variants
│   ├── fire/
│   │   ├── fire.gd            # CharacterBody2D, AI movement, burns items/trees
│   │   ├── fire.tscn          # AnimatedSprite2D, Hitbox, BurnRadius, timers
│   │   └── res/               # fire.png, fire.wav, burn.wav
│   └── item/
│       ├── item.gd            # Area2D, types: Seed, Refill, Medkit
│       ├── item.tscn
│       └── res/               # seed, refill, medkit, extinguisher_v2 (tool sprite)
├── ui/
│   ├── hud/
│   │   ├── ui.gd              # HUD script (layout, safe area, item selection, show/hide)
│   │   ├── UI.tscn            # CanvasLayer, Joystick, ActionButton, item slots
│   │   ├── virtual_joystick.gd # VirtualJoystick: floating stick, presses ui_left/right/up/down with analog strength
│   │   ├── touch_button.gd    # TouchButton: round button with its own finger tracking, optional input action
│   │   ├── status_panel.gd    # StatusPanel: health bar and item stock
│   │   └── res/               # Touch control sprites and digits (generated, see "Art Pipeline")
│   └── main_menu/             # Empty (not implemented)
├── assets/
│   ├── ASSET_SOURCES.md       # Asset sources and licences (many still unknown)
│   ├── atlas/                 # terrain_atlas.png (trees/stones source) + Attribution.txt
│   ├── tilesets/              # releaf_tileset.png/.tres (terrain autotiling, Releaf32 palette)
│   ├── palette/               # Releaf32 palette (.gpl, .png)
│   ├── icons/                 # PWA icons 144/180/512 (from icon.png: 512 nearest, others Lanczos)
│   ├── audio/                 # Sound effects (currently empty)
│   └── fonts/                 # Fonts (currently empty)
├── tools/                     # Dev tooling, .gdignore'd (invisible to Godot), see "Art Pipeline"
│   ├── STYLE_ANALYSIS.md      # Art style analysis, required reading before making assets
│   └── assets_gen/            # Python+Pillow asset generators (output/ is git-ignored)
├── icon.png                   # App icon (generated, see "Art Pipeline")
├── project.godot              # Godot project settings, autoloads, input map
├── export_presets.cfg         # Export presets
├── AGENTS.md                  # Agent instructions (auto-loaded)
└── PROJECT.md                 # This file
```

## Autoloads (Singletons)

| Autoload | Path | Purpose |
|----------|------|---------|
| `Global` | `core/autoloads/Global.gd` | Layer enums (`OBSTACLE`, `FIREABLE`, `ITEM`, `FIRE`, `TREE`, `STONE`, `WATER`) and layer masks |
| `Events` | `core/autoloads/Events.gd` | Global signal bus — all command signals (spawn, destroy, pick, plant, burn, quench, select, use) and `player_state_changed` |
| `Settings` | `core/autoloads/Settings.gd` | World and balance constants: item counts, health, tank, `STOCK_LIMITS`, `STOCK_START`; `get_world_rect()` returns `Rect2(-1600, -960, 3200, 1920)` |

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
| `SelectToolCommand` | `select_tool_command` | Player |
| `UseItemCommand` | `use_item_command` | Player |

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

Touch controls drive the same actions (see [UI/HUD](#uihud)).

## Player Mechanics

- **Movement**: WASD/arrows, gamepad or virtual joystick, up to 200 px/s. Polled in `_physics_process` because the joystick changes action state without sending input events. `move_and_slide` in floating mode, so the player slides along obstacles
- **Tools**: Always available. Press `1` for Shovel, `2` for Extinguisher, or tap a tool slot. All of them go through `SelectToolCommand`
- **Plant tree**: Select Shovel + press `ui_accept` (Enter/Space/action button). Spends one seed, does nothing without seeds
- **Extinguish fire**: Select Extinguisher + hold `ui_accept` near fire. A full tank lasts 20 s of spraying
- **Pick up items**: Walk into items with ActionBox (Area2D). Items go into stock; at the stock limit they stay on the ground, where fire can burn them, and are picked up once there is room and they are still in reach
- **Automatic items**: An empty tank loads a refill (1 s, no spraying meanwhile). A medkit is used at 30 health or below, restoring 50. Both also trigger right after pick-up if needed
- **Health**: 100 at start, fire deals 10 per second while the player is inside it. No death yet: health stops at 1 (`Settings.MIN_HEALTH`)
- **Camera**: Camera2D with 2x zoom, follows player

## World Generation

- **Background**: Generated at startup by `core/background.gd` from `assets/tilesets/releaf_tileset.tres`
  - 32x32 tiles, world is 100x60 tiles (3200x1920)
  - TileSet terrain set 0 (match corners and sides): `Grass`=0, `Road`=1, `Water`=2; blob-47 autotiling for road and water
  - Grass is filled randomly from 4 variants, then pond (ellipse, top right), horizontal road, vertical road and a winding path are painted with `set_cells_terrain_connect`
  - Flowers (~3%) and grass tufts (~5%) are scattered on plain grass only
- **Boundary**: collision walls and dark gradient (see `core/world.gd`, `core/world.gdshader`)
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

Tools (`PlayerTool.Type`) are always with the player and selected in the HUD. Items (`Item.Type`) lie in the world, are collected into a stock and are never selected. Rule of thumb: if the player decides where and when to apply it, it is a tool, otherwise an item.

| Tool | Texture | Purpose |
|------|---------|---------|
| `Shovel` | `shovel.png` | Plant a tree, spends a seed |
| `Extinguisher` | `extinguisher_v2.png` | Extinguish fires, spends the tank |

| Item | Texture | Start | Limit | Purpose |
|------|---------|-------|-------|---------|
| `Seed` | `seed.png` | 5 | 20 | Spent by the shovel |
| `Refill` | `refill.png` | 1 | 5 | Fills the tank when it runs out |
| `Medkit` | `medkit.png` | 1 | 3 | Restores health when it is low |

## UI/HUD

`CanvasLayer` with touch controls, laid out from code in `ui.gd`. Sizes are in units of a 720 px short side and scale with `min(width, height) / 720`; on mobile they keep clear of notches and gesture bars via the display safe area.

- **`Joystick`** (`VirtualJoystick`): floats, appearing under the thumb anywhere in the left half of the screen, and rests translucent in the bottom left corner. The base follows the thumb past the rim. Speed depends on tilt: below 12% of travel nothing moves, then strength ramps from 35% to 100% at 70% of travel
- **`ActionButton`** (`TouchButton`, bottom right): holds `ui_accept` until its finger lifts, even if the thumb slides off. Its icon shows the selected tool and dims when the tool can't act; with the extinguisher, pips around it show the tank
- **`Shovel`, `Extinguisher`** (`TouchButton`): tool slots fanned out around the action button, the selected one has a gold ring. Slots are placed from the `slots` dictionary in `ui.gd`, but the current arc (`SLOT_ARC_DEGREES`, `SLOT_DISTANCE`) fits only 2: slots are 84 wide with a 56 hit radius, so neighbours need about 112 between centres, and 3 slots here get 78
- **`StatusPanel`** (top left): health bar and the count of each item; a count at its limit turns gold. Digits come from a sprite sheet, the project has no font
- **Selection flow**: slots and keys send `SelectToolCommand`, the player handles it, and the HUD updates from `select_tool_processed`. Everything else on screen follows `Events.player_state_changed`
- **Visibility**: touch controls hide on keyboard or gamepad buttons and return on the next touch; `StatusPanel` always stays
- **Desktop testing**: `pointing/emulate_touch_from_mouse` is on, so the mouse acts as a single finger

