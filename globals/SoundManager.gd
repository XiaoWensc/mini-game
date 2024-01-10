extends Node
@onready var bgm_player: AudioStreamPlayer2D = $BGMPlayer

const SAVE_PATH = "user://settings.sav"

var _is_open := false

func _ready() -> void:
	_is_open = is_open_music()
	

func play_music(path: String) -> void:
	if bgm_player.playing and bgm_player.stream.resource_path == path:
		return
	bgm_player.stream = load(path)
	if not _is_open:
		return
	bgm_player.play()

func open_music() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data := {
		music=true
	}
	file.store_string(JSON.stringify(data))
	bgm_player.play()

func close_music() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data := {
		music=false
	}
	file.store_string(JSON.stringify(data))
	bgm_player.stop()
	
func is_open_music() -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json := file.get_as_text()
		var data := JSON.parse_string(json) as Dictionary
		return data.music
	else:
		return false
