extends Area2D

@export var dialog_before: Array[String] = [
	"Con este interruptor activas la luz para toda la mansión."
]

@export var puzzle_scene: PackedScene

var player_in_range := false
var puzzle_instance: Control = null

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
	# Si ya está la luz puesta, opcional: no repetir puzzle
	if GameState.power_on:
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.show_message("La luz ya está activada.")
		return

	var hud = get_tree().get_first_node_in_group("hud")
	if hud and dialog_before.size() > 0:
		hud.start_dialog(dialog_before)

	_open_puzzle()

func _open_puzzle() -> void:
	if not puzzle_scene:
		push_error("No has asignado puzzle_scene en el inspector.")
		return

	# Instanciar una sola vez
	if puzzle_instance == null:
		puzzle_instance = puzzle_scene.instantiate()
		get_tree().current_scene.add_child(puzzle_instance)

		# Conectar señales
		puzzle_instance.solved.connect(_on_puzzle_solved)
		puzzle_instance.failed.connect(_on_puzzle_failed)

	# Bloquear movimiento jugador mientras está abierto
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = false

	puzzle_instance.open()

func _on_puzzle_failed() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = true

	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_message("Fallaste. Inténtalo otra vez.")

func _on_puzzle_solved() -> void:
	# Activar luz global
	GameState.power_on = true

	# Quitar oscuridad en la sala actual
	var overlay = get_tree().current_scene.get_node_or_null("DarkOverlay")
	if overlay:
		overlay.visible = false

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = true

	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_message("¡Has activado la luz!")
