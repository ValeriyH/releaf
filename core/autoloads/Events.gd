extends Node

#Command signals
@warning_ignore_start("unused_signal")
signal item_spawn_command(command: ItemSpawnCommand)
signal item_spawn_processed(result: ItemSpawnCommand)
signal pick_item_command(command: PickItemCommand)
signal pick_item_processed(result: PickItemCommand)
signal item_destroy_command(command: ItemDestroyCommand)
signal item_destroy_processed(result: ItemDestroyCommand)
signal select_tool_command(command: SelectToolCommand)
signal select_tool_processed(result: SelectToolCommand)
signal use_item_command(command: UseItemCommand)
signal use_item_processed(result: UseItemCommand)

signal plant_tree_command(command: PlantTreeCommand)
signal plant_tree_processed(result: PlantTreeCommand)

signal burn_command(command: BurnCommand)
signal burn_processed(result: BurnCommand)
signal fire_quench_command(command: FireQuenchCommand)
signal fire_quench_processed(result: FireQuenchCommand)

#Event signals
signal player_state_changed(player: Player)
signal tree_grown
signal game_won
signal game_lost(reason: Global.LoseReason)
@warning_ignore_restore("unused_signal")
