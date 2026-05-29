extends Node

#Command signals
signal item_spawn_command(command: ItemSpawnContext)
signal item_spawn_processed(result: ItemSpawnContext)
signal plant_tree_command(command: PlantTreeContext)
signal plant_tree_processed(result: PlantTreeContext)

signal item_destroy_command(command: ItemDestroyContext)
signal item_destroy_processed(result: ItemDestroyContext)

signal burn_command(command: BurnContext)
signal burn_processed(result: BurnContext)

#Event signals
