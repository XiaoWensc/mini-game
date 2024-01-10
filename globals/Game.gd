extends Node

const SAVE_PATH = "user://data.sav"

## 状态记录
class Flags:
	signal changed
	
	var _flags := []
	
	func has(flag: String) -> bool:
		return flag in _flags
		
	func add(flag: String) -> void:
		if flag in _flags:
			return
		_flags.append(flag)
		changed.emit()
	
	func remove(flag: String) -> void:
		var index := _flags.find(flag)
		if index == -1:
			return
		_flags.remove_at(index)
		changed.emit()
		
	func to_dict() -> Dictionary:
		return {
			flags=_flags
		}
		
	func from_dict(dict: Dictionary) -> void:
		_flags = dict.flags
		changed.emit()
		
	func reset() -> void:
		_flags.clear()
		changed.emit()
	
## 背包	
class Inventory:
	signal changed
	
	var active_item: Item
	
	var _items: Array[Item] = []
	var _current_item_index := -1
	
	## 返回道具数量
	func get_item_count() -> int:
		return _items.size()
	
	## 返回当前选中的道具
	func get_current_item() -> Item:
		if _current_item_index == -1:
			return null
		return _items[_current_item_index]
	
	## 添加道具
	func add_item(item: Item) -> void:
		if item in _items:
			return
		_items.append(item)
		_current_item_index = _items.size() - 1
		changed.emit()
		
	## 删除道具
	func remove_item(item: Item) -> void:
		var index := _items.find(item)
		if index == -1:
			return
		_items.remove_at(index)
		if _current_item_index >= _items.size():
			_current_item_index = 0 if _items else -1
		changed.emit()
	
	## 下一个
	func select_next() -> void:
		if _current_item_index == -1:
			return
		_current_item_index = (_current_item_index + 1) % _items.size()
		changed.emit()
		
	
	## 上一个
	func select_prev() -> void:
		if _current_item_index == -1:
			return
		_current_item_index = (_current_item_index + _items.size() - 1) % _items.size()
		changed.emit()
		
	
	func to_dict() -> Dictionary:
		var names := []
		for item in _items:
			var path := item.resource_path
			names.append(path.get_file().get_basename())
		return {
			items=names,
			current_item_index=_current_item_index,
		}
		
	func from_dict(dict: Dictionary) -> void:
		_current_item_index = dict.current_item_index
		_items.clear()
		for name in dict.items:
			_items.append(load("res://items/%s.tres" % name))
		changed.emit()
		
	func reset() -> void:
		_current_item_index = -1
		_items.clear()
		changed.emit()
		

var flags: Flags = Flags.new()
var inventory: Inventory = Inventory.new()


func back_to_title() -> void:
	save_game()
	SceneChanger.change_scene("res://scenes/TitleScreen.tscn")

func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data := {
		inventory=inventory.to_dict(),
		flags=flags.to_dict(),
		current_scene=get_tree().current_scene.scene_file_path.get_file().get_basename(),
	}
	var json := JSON.stringify(data)
	file.store_string(json)
	
func load_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json := file.get_as_text()
	var data := JSON.parse_string(json) as Dictionary
	inventory.from_dict(data.inventory)
	flags.from_dict(data.flags)
	SceneChanger.change_scene("res://scenes/%s.tscn" % data.current_scene)
	
func new_game() -> void:
	inventory.reset()
	flags.reset()
	SceneChanger.change_scene("res://scenes/h_1.tscn")
	
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
