extends Node

#Command signals
@warning_ignore_start("unused_signal")
signal item_spawn_command(command: ItemSpawnCommand)
signal item_spawn_processed(result: ItemSpawnCommand)
signal pick_item_command(command: PickItemCommand)
signal pick_item_processed(result: PickItemCommand)
signal item_destroy_command(command: ItemDestroyCommand)
signal item_destroy_processed(result: ItemDestroyCommand)
signal select_item_command(command: SelectItemCommand)
signal select_item_processed(result: SelectItemCommand)

signal plant_tree_command(command: PlantTreeCommand)
signal plant_tree_processed(result: PlantTreeCommand)

signal burn_command(command: BurnCommand)
signal burn_processed(result: BurnCommand)
signal fire_quench_command(command: FireQuenchCommand)
signal fire_quench_processed(result: FireQuenchCommand)
@warning_ignore_restore("unused_signal")

#Event signals
