extends CanvasLayer

@onready var root: Control = $Root
@onready var fade: ColorRect = $Root/Fade
@onready var title: Label = $Root/Title

func _ready() -> void:
	# Asegura que ocupa toda la pantalla siempre
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 0
	root.offset_top = 0
	root.offset_right = 0
	root.offset_bottom = 0

	# Fade-in suave 
	fade.modulate.a = 1.0
	var t := create_tween()
	t.tween_property(fade, "modulate:a", 0.0, 0.6)

	# Texto centrado “a prueba de cámaras”
	title.text = "Fin de la partida"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
