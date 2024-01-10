@tool
extends Interactable
class_name SceneItem

@export var item: Item:
	set(v):
		item = v
		texture = item.scene_texture if item else null
		notify_property_list_changed()

func _ready() -> void:
	# 在编辑器中
	if Engine.is_editor_hint():
		return
	if Game.flags.has(_get_flag()):
		queue_free()

func _interact() -> void:
	super._interact()
	
	Game.flags.add(_get_flag())
	Game.inventory.add_item(item)
	
	var sprite := Sprite2D.new()
	sprite.texture = item.scene_texture
	get_parent().add_child(sprite)
	sprite.global_position = global_position
	
	var tween := sprite.create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.15)
	tween.tween_callback(sprite.queue_free)
	
	queue_free()


func _get_flag():
	return "picked:" + item.resource_path.get_file()
