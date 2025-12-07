extends Area2D

@export var dialog_lines: Array[String] = [
	"Se implementará aquí la lógica para que puedas guardar tu partida.",
	"Sigue investigando ...",
]

var player_in_range: bool = false

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_range = true
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.show_message("Pulsa E para interactuar")

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
	
	# Mostrar el diálogo de la safeRoom
	hud.start_dialog(dialog_lines)
