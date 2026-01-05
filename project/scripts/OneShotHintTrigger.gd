extends Area2D

@export var flag_id: String = ""
@export var message: String = ""
@export var requires_flag_id: String = ""   # si está vacío, no exige nada
@export var requires_power_off: bool = false # opcional: solo si NO hay electricidad

var _fired := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _fired:
		return
	if not body.is_in_group("player"):
		return
	if flag_id != "" and GameState.has_flag(flag_id):
		_fired = true
		return

	# condición extra: exige otra flag (por ejemplo "entered_save_room_once")
	if requires_flag_id != "" and not GameState.has_flag(requires_flag_id):
		return

	# condición extra: solo si NO hay electricidad
	if requires_power_off and GameState.power_on:
		return

	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_pickup_dialog(message)

	if flag_id != "":
		GameState.set_flag(flag_id, true)

	_fired = true
