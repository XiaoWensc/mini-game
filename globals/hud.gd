extends CanvasLayer


func _ready() -> void:
	SceneChanger.game_entered.connect(show)
	SceneChanger.game_exited.connect(hide)
	visible = get_tree().current_scene is Scene


func _on_menu_pressed() -> void:
	Game.back_to_title()
