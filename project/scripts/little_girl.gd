extends Area2D


@export var key_id: String = "key_living_room"  
@export var dialog_lines: Array[String] = [
	"...",
	"No deberías estar aquí.",
	"Toma esta llave para bajar al salón... pero no hagas ruido, es peligroso."
]

var player_in_range: bool = false
var has_given_key: bool = false

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_range = true
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.show_message("Pulsa E para hablar")


func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_in_range = false


func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		interact()

func _ready() -> void:
	# Si el jugador ya tiene la llave, marcamos que ya se la hemos dado
	has_given_key = GameState.has_key(key_id)

func interact() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if not hud:
		return
	
	# Dar la llave solo la primera vez
	if not has_given_key:
		has_given_key = true
		GameState.add_key(key_id)
		hud.show_pickup_dialog("Has obtenido una llave.")
	
	# Mostrar el diálogo de la niña
	hud.start_dialog(dialog_lines)
