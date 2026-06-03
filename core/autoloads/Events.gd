extends Node

#Command signals
@warning_ignore_start("unused_signal")
signal item_spawn_command(command: ItemSpawnCommand)
signal item_spawn_processed(result: ItemSpawnCommand)
signal pick_item_command(command: PickItemCommand)
signal pick_item_processed(result: PickItemCommand)
signal item_destroy_command(command: ItemDestroyCommand)
signal item_destroy_processed(result: ItemDestroyCommand)

signal plant_tree_command(command: PlantTreeCommand)
signal plant_tree_processed(result: PlantTreeCommand)

signal burn_command(command: BurnCommand)
signal burn_processed(result: BurnCommand)
@warning_ignore_restore("unused_signal")

#Event signals
