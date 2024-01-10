extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

signal game_entered
signal game_exited

func _ready() -> void:
	_on_scene_changed(null, get_tree().current_scene)

func change_scene(path: String) -> void:
	var tween := create_tween()
	tween.tween_callback(color_rect.show)
	tween.tween_property(color_rect, "color:a", 1.0, 0.2)
	tween.tween_callback(_change_scene.bind(path))
	tween.tween_property(color_rect, "color:a", 0.0, 0.3)
	tween.tween_callback(color_rect.hide)

func _change_scene(path: String) -> void:
	print("打开场景: %s" % path)
	var old_scene := get_tree().current_scene
	var new_scene := load(path).instantiate() as Node
	
	var root := get_tree().root
	root.remove_child(old_scene)
	root.add_child(new_scene)
	get_tree().current_scene = new_scene
	
	_on_scene_changed(old_scene, new_scene)
	
	old_scene.queue_free()
	

func _on_scene_changed(old_scene: Node, new_scene: Node) -> void:
	var was_in_game := old_scene is Scene
	var is_in_game := new_scene is Scene
	if was_in_game != is_in_game:
		if is_in_game:
			game_entered.emit()
		else:
			game_exited.emit()
			
	var music := "res://assets/Music/PaperWings.mp3"
	if is_in_game and new_scene.music_override:
		music = new_scene.music_override
	SoundManager.play_music(music)
