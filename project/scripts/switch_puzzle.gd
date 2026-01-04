extends Control

signal solved
signal failed

@export var correct_sequence: Array[int] = [3, 1, 2]

@onready var anim: AnimatedSprite2D = $SwitchAnim
@onready var hint: Label = $HintLabel

var input_sequence: Array[int] = []
var active: bool = false

func open() -> void:
	visible = true
	active = true
	input_sequence.clear()

	# Frame inicial (todo apagado / estado base)
	anim.frame = 0

	if hint:
		hint.text = "Pulsa las teclas 1, 2 o 3 para ativar los interruptores (Esc para salir)"

func close() -> void:
	active = false
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return

	if event.is_action_pressed("ui_cancel"):
		# salir = fallo / cancelar intento
		close()
		emit_signal("failed")
		return

	# Capturamos 1,2,3
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_register_press(1)
			KEY_2:
				_register_press(2)
			KEY_3:
				_register_press(3)

func _register_press(n: int) -> void:
	input_sequence.append(n)

	# Actualiza el frame según estado actual
	_update_frame()

	# Comprueba si el orden va bien (prefijo correcto)
	for i in range(input_sequence.size()):
		if input_sequence[i] != correct_sequence[i]:
			# Se equivocó: cerrar y notificar fallo
			close()
			emit_signal("failed")
			return

	# Si ya completó los 3 correctamente
	if input_sequence.size() == correct_sequence.size():
		close()
		emit_signal("solved")

func _update_frame() -> void:
	# Aquí mapeamos "qué interruptores están activados" -> frame
	var mask := 0
	for v in input_sequence:
		if v == 1: mask |= 1
		if v == 2: mask |= 2
		if v == 3: mask |= 4

	# MAPEO mask -> frame
	# 0: ninguno
	# 1: solo 1
	# 2: solo 2
	# 4: solo 3
	# 3: 1+2
	# 5: 1+3
	# 6: 2+3
	# 7: 1+2+3
	var frame_map := {
		0: 0,
		1: 1,
		2: 2,
		4: 3,
		3: 4,
		5: 5,
		6: 6,
		7: 7
	}

	if frame_map.has(mask):
		anim.frame = frame_map[mask]
