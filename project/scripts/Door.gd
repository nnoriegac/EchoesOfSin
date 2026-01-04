extends Area2D

@export var world_id: String = ""          # ej: "door_garden_to_hall_01"
@export var target_scene: String = ""      # ruta a la escena destino
@export var locked: bool = false           # si está cerrada
@export var required_key: String = ""      # id de la llave (si locked = true)
@export var consume_key: bool = true       # si se “gasta” la llave al abrir
@export var set_flag_on_use: String = ""

func _ready() -> void:
	# Si esta puerta ya fue abierta en una partida, se queda abierta
	if world_id != "" and GameState.is_door_opened(world_id):
		locked = false
		return

	# Si la puerta requiere llave y el jugador YA la tiene, opcionalmente arrancamos desbloqueada
	# (esto lo puedes dejar o quitar según tu diseño)
	if required_key != "" and GameState.has_key(required_key):
		locked = false


func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return

	if locked:
		if required_key != "" and GameState.has_key(required_key):
			# Marcar puerta como abierta PARA SIEMPRE
			if world_id != "":
				GameState.set_door_opened(world_id)

			# Consumir la llave si quieres (personalmente yo NO la consumiría,
			# pero te dejo el toggle)
			if consume_key:
				GameState.keys.erase(required_key)

			locked = false
			change_scene()
		else:
			var hud = get_tree().get_first_node_in_group("hud")
			if hud:
				hud.show_pickup_dialog("Está cerrada. Parece que necesita una llave...")
	else:
		if set_flag_on_use != "":
			GameState.set_flag(set_flag_on_use, true)
		change_scene()


func change_scene() -> void:
	if target_scene == "":
		push_warning("Door sin target_scene asignado")
		return

	get_tree().change_scene_to_file(target_scene)
