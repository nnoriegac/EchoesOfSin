extends Area2D

@export var target_scene: String = ""      # ruta a la escena destino
@export var locked: bool = false           # si está cerrada
@export var required_key: String = ""      # id de la llave (si locked = true)cess(delta: float) -> void:



func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	
	if locked:
		if GameState.has_key(required_key):
			# "gastar" la llave, de momento solo se usarán una vez
			GameState.keys.erase(required_key)
			change_scene()
		else:
			# Mensaje de que está cerrada
			var hud = get_tree().get_first_node_in_group("hud")
			if hud:
				hud.show_pickup_dialog("Está cerrada. Parece que necesita una llave...")
	else:
		change_scene()
	
func change_scene() -> void:
	if target_scene == "":
		push_warning("Door sin target_scene asignado")
		return
	
	get_tree().change_scene_to_file(target_scene)

func _ready() -> void:
	# Si la puerta requiere llave y el jugador YA la tiene, arrancamos desbloqueada
	if required_key != "" and GameState.has_key(required_key):
		locked = false
