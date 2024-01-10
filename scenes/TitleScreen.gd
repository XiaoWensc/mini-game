extends TextureRect
@onready var load: Button = $VBoxContainer/Load
@onready var settings: CheckButton = $VBoxContainer/Settings
@onready var music_settings: CheckButton = $VBoxContainer/MusicSettings


func _ready() -> void:
	load.disabled = not Game.has_save_file()
	music_settings.button_pressed = SoundManager.is_open_music()
		

func _on_new_pressed() -> void:
	Game.new_game()


func _on_load_pressed() -> void:
	Game.load_game()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_settings_toggled(toggled_on: bool) -> void:
	music_settings.visible = toggled_on


func _on_music_settings_toggled(toggled_on: bool) -> void:
	if toggled_on:
		SoundManager.open_music()
	else:
		SoundManager.close_music()
	
