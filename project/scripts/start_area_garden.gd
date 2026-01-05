extends Node2D

@export var intro_lines: Array[String] = [
	"Amaneces frío y empapado. No recuerdas cómo has llegado aquí… ni quién eres."
]

func _ready() -> void:
	if GameState.has_flag("intro_garden_done"):
		return
	GameState.set_flag("intro_garden_done", true)
	
	await get_tree().process_frame  # asegura que HUD/Player ya están listos

	var hud = get_tree().get_first_node_in_group("hud")
	var player = get_tree().get_first_node_in_group("player")

	# Bloquea al jugador mientras hace el intro (por si acaso)
	if player and "can_move" in player:
		player.can_move = false

	# Parpadeo
	if hud and hud.has_method("flash"):
		await hud.flash(0.10, 2)

	# Diálogo
	if hud and hud.has_method("start_dialog"):
		hud.start_dialog(intro_lines)
		await hud.dialog_finished

	# Deja mover
	if player and "can_move" in player:
		player.can_move = true
