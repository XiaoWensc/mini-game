@tool
extends Interactable
class_name Teleporter

@export_file("*.tscn") var target_path

func _interact() -> void:
	super._interact()
	SceneChanger.change_scene(target_path)
