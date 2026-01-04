extends Area2D

@export var dialog_lines: Array[String] = [
	"Es un dibujo hecho por la pequeña Elena.",
	"Parece es ella, el ser que apareció antes en el pasillo y tú.",
	"Los tres cogidos de la mano, que extraño ..."
]

var player_in_range: bool = false
var has_given_heal: bool = false

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
	# Mostrar el diálogo
	hud.start_dialog(dialog_lines)
