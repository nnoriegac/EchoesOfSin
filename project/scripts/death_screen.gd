extends CanvasLayer

@onready var root: Control = $Root
@onready var button: Button = $Root/Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 0
	root.offset_top = 0
	root.offset_right = 0
	root.offset_bottom = 0

	button.pressed.connect(_on_retry_pressed)
	button.grab_focus()

func _on_retry_pressed() -> void:
	print("DeathScreen: RESTART pressed")

	var tree := get_tree()
	if tree == null:
		return

	# Método más fiable que reload_current_scene
	if tree.current_scene and tree.current_scene.scene_file_path != "":
		var path := tree.current_scene.scene_file_path
		tree.change_scene_to_file(path)
	else:
		# Fallback
		tree.reload_current_scene()
