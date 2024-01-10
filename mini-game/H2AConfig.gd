@tool
extends Resource
class_name H2AConfig

var hammer_type = 0

enum Slot {
	NULL,
	TIME,
	SUN,
	FISH,
	HILL,
	CROSS,
	CHOICE,
}

var placements := PackedInt64Array()
var connections := {}

func _init() -> void:
	placements.resize(Slot.size())
	placements.fill(Slot.NULL)
	
	for slot in Slot.values():
		connections[slot] = []

func _get_property_list():
	var propertys := [
		{
			"name":"placements",
			"type":TYPE_PACKED_INT64_ARRAY,
			"usage":PROPERTY_USAGE_STORAGE,
		},
		{
			"name":"connections",
			"type":TYPE_DICTIONARY,
			"usage":PROPERTY_USAGE_STORAGE,
		},
	]
	var options := ",".join(PackedStringArray(Slot.keys()))
	for slot in range(1, Slot.size()):
		propertys.append({
			"name":"placements/" + Slot.keys()[slot],
			"type":TYPE_INT,
			"usage":PROPERTY_USAGE_EDITOR,
			"hint":PROPERTY_HINT_ENUM,
			"hint_string":options,
		})
		
	for slot in Slot.size() - 1:
		var available := PackedStringArray()
		for dst in Slot.size():
			if dst <= slot:
				available.append("")
			else:
				available.append(Slot.keys()[dst])
		propertys.append({
			"name":"connections/" + Slot.keys()[slot],
			"type":TYPE_INT,
			"usage":PROPERTY_USAGE_EDITOR,
			"hint":PROPERTY_HINT_FLAGS,
			"hint_string":",".join(available),
		})
	return propertys

func _get(property: StringName) -> Variant:
	if property.begins_with("placements/"):
		property = property.trim_prefix("placements/")
		var index := Slot[property] as int
		return placements[index]
		
	if property.begins_with("connections/"):
		property = property.trim_prefix("connections/")
		var index := Slot[property] as int
		var value := 0
		for dst in range(index + 1, Slot.size()):
			if dst in connections[index]:
				value |= (1 << dst)
		return value
	return null
	
func _set(property: StringName, value: Variant) -> bool:
	if property.begins_with("placements/"):
		property = property.trim_prefix("placements/")
		var index := Slot[property] as int
		placements[index] = value
		changed.emit()
		return true
	if property.begins_with("connections/"):
		property = property.trim_prefix("connections/")
		var index := Slot[property] as int
		for dst in range(index + 1, Slot.size()):
			_set_connected(index, dst, value & (1 << dst))
		changed.emit()
		return true
	return false

func _set_connected(src: int, dst: int, connected: bool) -> void:
	var src_arr := connections[src] as Array
	var dst_arr := connections[dst] as Array
	var src_index := src_arr.find(dst)
	var dst_index := dst_arr.find(src)
	if connected:
		if src_index == -1:
			src_arr.append(dst)
		if dst_index == -1:
			dst_arr.append(src)
	else:
		if src_index != -1:
			src_arr.remove_at(src_index)
		if dst_index != -1:
			dst_arr.remove_at(dst_index)
