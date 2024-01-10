extends VBoxContainer

@onready var label: Label = $Label
@onready var prev: TextureButton = $ItemBar/prev
@onready var prop: Sprite2D = $ItemBar/use/prop
@onready var hand: Sprite2D = $ItemBar/use/hand
@onready var next: TextureButton = $ItemBar/next
@onready var timer: Timer = $Label/Timer

var _hand_outro: Tween
var _label_outro: Tween

func _ready() -> void:
	#Game.inventory.add_item(preload("res://items/key.tres"))
	#Game.inventory.add_item(preload("res://items/email.tres"))
	hand.hide()
	hand.modulate.a = 0.0
	label.modulate.a = 0.0
	Game.inventory.changed.connect(_update_ui)
	_update_ui()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and Game.inventory.active_item:
		Game.inventory.set_deferred("active_item", null) # 当前帧结果后执行
		_hand_outro = create_tween()
		_hand_outro.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
		_hand_outro.tween_property(hand, "scale", Vector2.ONE * 2, 0.15)
		_hand_outro.tween_property(hand, "modulate:a", 0.0, 0.15)
		_hand_outro.chain().tween_callback(hand.hide)
	
func _update_ui(is_init := false) -> void:
	var count := Game.inventory.get_item_count()
	prev.disabled = count < 2
	next.disabled = count < 2
	visible = count > 0
	
	var item := Game.inventory.get_current_item()
	if not item:
		return
		
	label.text = item.description
	prop.texture = item.prop_texture
	
	if is_init:
		return
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(prop, "scale", Vector2.ONE, 0.15).from(Vector2.ZERO)
	
func _show_label() -> void:
	if _label_outro and _label_outro.is_valid():
		_label_outro.kill()
		_label_outro = null
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(label, "modulate:a", 1.0, 0.2)
	tween.tween_callback(timer.start)
	

func _on_prev_pressed() -> void:
	Game.inventory.select_prev()
	_show_label()


func _on_use_pressed() -> void:
	Game.inventory.active_item = Game.inventory.get_current_item()
	
	if _hand_outro and _hand_outro.is_valid():
		_hand_outro.kill()
		_hand_outro = null
	hand.show()
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel()
	tween.tween_property(hand, "scale", Vector2.ONE, 0.15)
	tween.tween_property(hand, "modulate:a", 1.0, 0.15)
	
	_show_label()


func _on_next_pressed() -> void:
	Game.inventory.select_next()
	_show_label()


func _on_timer_timeout() -> void:
	_label_outro = create_tween()
	_label_outro.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_label_outro.tween_property(label, "modulate:a", 0.0, 0.2)

