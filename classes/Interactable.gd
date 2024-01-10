@tool
extends Area2D
class_name Interactable

signal interact

## 是否接收道具
@export var allow_item := false
@export var texture: Texture:
	set(value):
		texture = value
		
		for node in get_children():
			if node.owner == null:
				node.queue_free()
		
		if value == null:
			return
		
		var sprite := Sprite2D.new()
		sprite.texture = value
		add_child(sprite)
		
		var rect: RectangleShape2D = RectangleShape2D.new()
		rect.extents = value.get_size() / 2
		
		var collider := CollisionShape2D.new()
		collider.shape = rect
		add_child(collider)
		

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if not event.is_action_pressed("interact"):
		return
	if not allow_item and Game.inventory.active_item:
		return
	_interact()
	
func _interact() -> void:
	interact.emit()
