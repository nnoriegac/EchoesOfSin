extends Area2D

@export var key_id: String = "key_room2" 
@export var dialog_lines: Array[String] = [
	"Parece que hay algo en este cajón.",
	"Has obtenido una llave."
]

var player_in_range: bool = false
var has_given_key: bool = false

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
	
	# Dar la cura solo la primera vez
	if not has_given_key:
		has_given_key = true
		GameState.add_key(key_id)
	
	# Mostrar el diálogo
	hud.start_dialog(dialog_lines)
