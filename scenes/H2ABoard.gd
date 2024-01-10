@tool
extends Node2D

const SLOT_TEXTURE = preload("res://assets/H2A/CIRCLE.png")
const LINE_TEXTURE = preload("res://assets/H2A/CIRCLELINE.png")


var _stone_map := {}

@export var radius := 100.0
@export var config: H2AConfig:
	set(v):
		if config and config.is_connected("changed", _update_board):
			config.disconnect("changed", _update_board)
		config = v
		if config and not config.is_connected("changed", _update_board):
			config.connect("changed", _update_board)
		_update_board()

func _draw() -> void:
	for slot in H2AConfig.Slot.values():
		draw_texture(SLOT_TEXTURE, _get_slot_position(slot) - SLOT_TEXTURE.get_size() / 2)

## 画线
func _update_board() -> void:
	for node in get_children():
		if node.owner == null:
			node.queue_free()
	
	if not config:
		return
	
	for src in H2AConfig.Slot.values():
		for dst in config.connections[src]:
			if src >= dst:
				continue
			_draw_board(src, dst)
	
	for slot in range(1, H2AConfig.Slot.size()):
		var stone := H2AStone.new()
		add_child(stone)
		stone.target_slot = slot
		stone.current_slot = config.placements[slot]
		stone.position = _get_slot_position(stone.current_slot)
		_stone_map[slot] = stone
		stone.interact.connect(_request_move.bind(stone))
		

func _request_move(stone: H2AStone) -> void:
	var available := H2AConfig.Slot.values()
	for s in _stone_map.values():
		available.erase(s.current_slot)
	assert(available.size() == 1)
	var available_slot := available.front() as int
	if available_slot in config.connections[stone.current_slot]:
		_move_slot(stone, available_slot)
		

func _move_slot(stone: H2AStone, slot: int) -> void:
	stone.current_slot = slot
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(stone, "position", _get_slot_position(slot), 0.2)
	tween.tween_interval(1.0)
	tween.tween_callback(_check)
	
func _check() -> void:
	for stone in _stone_map.values():
		if stone.current_slot != stone.target_slot:
			return
	Game.flags.add("h2a_unlocked")
	SceneChanger.change_scene("res://scenes/h_2.tscn")
	
	
func _draw_board(src: H2AConfig.Slot, dst: H2AConfig.Slot) -> void:
	var line := Line2D.new()
	add_child(line)
	line.add_point(_get_slot_position(src))
	line.add_point(_get_slot_position(dst))
	line.width = LINE_TEXTURE.get_size().y
	line.texture = LINE_TEXTURE
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.default_color = Color.WHITE
	line.show_behind_parent = true

func _get_slot_position(slot: H2AConfig.Slot) -> Vector2:
	return Vector2.DOWN.rotated(TAU / H2AConfig.Slot.values().size() * slot) * radius
