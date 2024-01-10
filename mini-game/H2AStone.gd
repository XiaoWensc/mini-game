@tool
extends Interactable
class_name H2AStone

## 目标位置
var target_slot: int:
	set(v):
		target_slot = v
		_update_texture()
		
## 当前位置
var current_slot: int:
	set(v):
		current_slot = v
		_update_texture()
		
func _update_texture():
	var index := target_slot
	if target_slot != current_slot:
		index += H2AConfig.Slot.size() - 1
	texture = load("res://assets/H2A/SS_%02d.png" % index)
