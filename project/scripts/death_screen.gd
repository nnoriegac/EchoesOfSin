# res://scenes/DeathScreen.gd
extends CanvasLayer

@onready var root: Control = $Root
@onready var button: Button = $Root/Button

func _ready() -> void:
	# Root ocupa toda la pantalla, independientemente de cámara/posición
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 0
	root.offset_top = 0
	root.offset_right = 0
	root.offset_bottom = 0

	button.pressed.connect(_on_retry_pressed)

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()
