extends Area2D

@export var world_id: String = ""         
@export var target_scene: String = ""      # ruta a la escena destino
@export var locked: bool = false           # si está cerrada
@export var required_key: String = ""      # id de la llave (si locked = true)
@export var consume_key: bool = true       # si se “gasta” la llave al abrir
@export var set_flag_on_use: String = ""

@export var requires_pin: bool = false
@export var pin_flag_id: String = ""              # lab_pin_unlocked"
@export var pin_puzzle_scene: PackedScene         # PuzzlePin.tscn
@export var msg_need_pin := "La llave encaja... pero pide un PIN."
@export var msg_wrong_pin := "PIN incorrecto. Inténtalo otra vez."

var _pin_instance: Control = null
var _waiting_for_pin: bool = false

func _ready() -> void:
	# Si esta puerta ya fue abierta en una partida, se queda abierta
	if world_id != "" and GameState.is_door_opened(world_id):
		locked = false
		return

	# Si la puerta requiere llave y el jugador YA la tiene, opcionalmente arrancamos desbloqueada
	# (esto lo puedes dejar o quitar según tu diseño)
	if required_key != "" and GameState.has_key(required_key) and not requires_pin:
		locked = false 


func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	
	# Evitar reentradas si ya está el puzzle abierto
	if _waiting_for_pin:
		return
	
	if locked:
		if required_key != "" and GameState.has_key(required_key):
			
			# --- Si además requiere PIN, lo pedimos antes de abrir ---
			if requires_pin:
				# si ya estaba validado el pin previamente, abre directo
				if pin_flag_id != "" and GameState.has_flag(pin_flag_id):
					_unlock_and_go()
				else:
					_ask_for_pin()
				return
			
			# --- Caso normal: llave abre ---
			_unlock_and_go()
			
		else:
			var hud = get_tree().get_first_node_in_group("hud")
			if hud:
				hud.show_pickup_dialog("Está cerrada. Parece que necesita una llave...")
	else:
		if set_flag_on_use != "":
			GameState.set_flag(set_flag_on_use, true)
		change_scene()

func _ask_for_pin() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_pickup_dialog(msg_need_pin)

	if not pin_puzzle_scene:
		push_error("Door requires_pin=true pero no tiene pin_puzzle_scene asignado.")
		return
	if pin_flag_id == "":
		push_error("Door requires_pin=true pero pin_flag_id está vacío.")
		return

	if _pin_instance == null:
		_pin_instance = pin_puzzle_scene.instantiate()
		get_tree().current_scene.add_child(_pin_instance)

		_pin_instance.solved.connect(_on_pin_solved)
		_pin_instance.failed.connect(_on_pin_failed)

	_waiting_for_pin = true

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = false

	_pin_instance.open()


func _on_pin_failed() -> void:
	# El puzzle se resetea solo y sigue abierto para reintentar.
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_pickup_dialog(msg_wrong_pin)


func _on_pin_solved() -> void:
	GameState.set_flag(pin_flag_id, true)

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = true

	_waiting_for_pin = false

	_unlock_and_go()


func _unlock_and_go() -> void:
	# Marcar puerta como abierta PARA SIEMPRE
	if world_id != "":
		GameState.set_door_opened(world_id)

	# Consumir la llave si quieres
	if consume_key and required_key != "":
		GameState.keys.erase(required_key)

	locked = false
	change_scene()

func change_scene() -> void:
	if target_scene == "":
		push_warning("Door sin target_scene asignado")
		return

	get_tree().change_scene_to_file(target_scene)
