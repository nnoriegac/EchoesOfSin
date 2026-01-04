extends Area2D


@export var save_code: String = "0427"  
# código de 4 dígitos, pista para puzzle lab

@export var dialog_template: Array[String] = [
	"REGISTRO DE ACTIVIDAD",
	"--------------------",
	"Entrada: {CODE}",
	"Estado: Guardado correctamente."
]

var player_in_range: bool = false
var has_saved: bool = false   # evita spamear el guardado

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_range = true
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.show_message("Pulsa E para interactuar")

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_in_range = false

func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		interact()

func interact() -> void:
	if has_saved:
		_show_already_saved()
		return

	# 1. Guardar partida
	GameState.save_game()

	has_saved = true

	# 2. Mostrar registro antiguo
	var hud = get_tree().get_first_node_in_group("hud")
	if not hud:
		return

	var dialog: Array[String] = []
	for line in dialog_template:
		dialog.append(line.replace("{CODE}", save_code))

	hud.start_dialog(dialog)

func _show_already_saved() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if not hud:
		return

	hud.start_dialog([
		"REGISTRO DE ACTIVIDAD",
		"--------------------",
		"No se han detectado cambios."
	])
