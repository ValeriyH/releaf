extends CanvasLayer


func on_seed_pressed() -> void:
	$ActionButton.texture_normal = Item.TEXTURES[Item.Type.Seed]
	SelectItemCommand.new(self, Item.Type.Seed).send()


func on_extinguisher_pressed() -> void:
	$ActionButton.texture_normal = Item.TEXTURES[Item.Type.Extinguisher]
	SelectItemCommand.new(self, Item.Type.Extinguisher).send()
