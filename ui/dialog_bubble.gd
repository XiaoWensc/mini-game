extends Control

@onready var label: Label = $Label

var _messages: PackedStringArray = []
var _current_line: int = -1

func _ready() -> void:
	hide()
	
func show_dialog(messages: Array) -> void:
	_messages = messages
	_advance()
	
func _show_line(line: int) -> void:
	_current_line = line
	label.text = _messages[_current_line]
	show()

func _advance():
	if _current_line + 1 < _messages.size():
		_show_line(_current_line + 1)
	else:
		_current_line = -1
		hide()


func _on_label_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_advance()
