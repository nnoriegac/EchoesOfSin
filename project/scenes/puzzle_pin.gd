extends Control

signal solved
signal failed

@export var correct_code: String = "0427"
@export var max_digits: int = 4

@onready var hint: Label = $HintLabel
@onready var code_label: Label = $CodeLabel

var input_code: String = ""
var active: bool = false

func open() -> void:
	visible = true
	active = true
	_reset()

	if hint:
		hint.text = "Introduce el PIN (0-9). Enter para confirmar, Backspace para borrar, Esc para salir."

func close() -> void:
	active = false
	visible = false

func _reset() -> void:
	input_code = ""
	_update_ui()

func _update_ui() -> void:
	if code_label:
		code_label.text = input_code

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return

	if event.is_action_pressed("ui_cancel"):
		close()
		emit_signal("failed") # cancelar intento
		return

	if event is InputEventKey and event.pressed and not event.echo:
		# borrar
		if event.keycode == KEY_BACKSPACE:
			if input_code.length() > 0:
				input_code = input_code.substr(0, input_code.length() - 1)
				_update_ui()
			return

		# confirmar
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_check_code()
			return

		# dígitos (teclado normal y numpad)
		var digit := _keycode_to_digit(event.keycode)
		if digit != "":
			if input_code.length() < max_digits:
				input_code += digit
				_update_ui()

				# (sonido "piip" aquí en el futuro)
				# $Beep.play()

				# si ya llegó a 4, auto-check 
				if input_code.length() == max_digits:
					_check_code()
			return

func _check_code() -> void:
	if input_code == correct_code:
		close()
		emit_signal("solved")
	else:
		# fallo: resetea pero NO cierres
		_reset()
		emit_signal("failed")

func _keycode_to_digit(keycode: int) -> String:
	match keycode:
		KEY_0, KEY_KP_0: return "0"
		KEY_1, KEY_KP_1: return "1"
		KEY_2, KEY_KP_2: return "2"
		KEY_3, KEY_KP_3: return "3"
		KEY_4, KEY_KP_4: return "4"
		KEY_5, KEY_KP_5: return "5"
		KEY_6, KEY_KP_6: return "6"
		KEY_7, KEY_KP_7: return "7"
		KEY_8, KEY_KP_8: return "8"
		KEY_9, KEY_KP_9: return "9"
		_: return ""
