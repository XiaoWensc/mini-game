extends FlagSwitch



func _on_interactable_interact() -> void:
	var item := Game.inventory.active_item
	if item and item == preload("res://items/key.tres"):
		Game.flags.add(flag)
		Game.inventory.remove_item(item)
