extends Area2D


@export var weapon_id: String = "weapon_CountersRoom"  
@export var question: String = 	"¿Quieres coger un arma?"

var player_in_range: bool = false

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_range = true
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.show_message("Pulsa E para inspeccionar")


func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_in_range = false


func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		interact()

func interact() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if not hud:
		return
	
	# Si ya tienes el arma, no preguntes
	if GameState.has_item(weapon_id):
		hud.show_pickup_dialog("Ya has cogido el arma.")
		return
	
	# Pregunta Sí/No
	hud.start_choice(question, ["Sí", "No"], Callable(self, "_on_choice"))

func _on_choice(index: int, _option_text: String) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	
	# index 0 = Sí
	if index == 0:
		GameState.add_item(weapon_id)

		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("unlock_weapon"):
			player.unlock_weapon(weapon_id)

		if hud:
			hud.show_pickup_dialog("Has obtenido un arma.")
	else:
		if hud:
			hud.show_message("Has decidido no cogerla.")
