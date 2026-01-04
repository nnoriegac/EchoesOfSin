extends Node2D

enum WomanState { HURTED, HEALED, DEAD }

@export var interact_action: StringName = &"interact"  # tu InputMap para la E
@export var key_id: String = "key_lab"
@export var helped_flag_id: String = "woman_helped"
@export var not_helped_flag_id: String = "woman_not_helped"
@export var killed_flag_id: String = "woman_killed"
@export var hits_to_die: int = 2

@onready var anim: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var interact_area: Area2D = get_node_or_null("InteractArea")


var state: WomanState = WomanState.HURTED
var player_in_range: bool = false
var hits: int = 0

func _ready() -> void:
	anim.play("hurted")
	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)

	# Si alguna vez guardas flags/keys y al cargar quieres reflejarlo:
	if GameState.has_flag(killed_flag_id):
		queue_free()
		return
	if GameState.has_flag(helped_flag_id):
		state = WomanState.HEALED
		anim.play("healed")
	elif GameState.has_flag(not_helped_flag_id):
		state = WomanState.HURTED
		anim.play("hurted")

func _process(_delta: float) -> void:
	if state == WomanState.DEAD:
		return

	if player_in_range and Input.is_action_just_pressed(interact_action):
		_interact()

func _interact() -> void:
	var hud = get_tree().get_first_node_in_group("hud")

	if state == WomanState.HURTED:
		# Si ya decidió NO antes, no volvemos a preguntar. Solo recordatorio.
		if GameState.has_flag(not_helped_flag_id):
			if hud:
				hud.start_dialog(["Sigue llorando… No parece confiar en ti."])
			return

		if hud:
			hud.start_choice(
				"Está herida… ¿Quieres curarla?",
				["Sí", "No"],
				Callable(self, "_on_heal_choice")
			)
		return

	if state == WomanState.HEALED:
		# Da la llave una vez (si ya la tiene por "no" o por muerte, no repite)
		if not GameState.has_key(key_id):
			if hud:
				hud.start_dialog([
					"Me herí en el laboratorio intentando cerrarlo con llave para que no escapara…",
					"Toma. Esta es la llave del laboratorio."
				])
			GameState.add_key(key_id)
			GameState.set_flag("got_lab_key", true)
		else:
			if hud:
				hud.start_dialog(["Ten cuidado… ahí dentro no estáis a salvo."])
		return

func _on_heal_choice(selected_index: int, selected_text: String) -> void:
	var hud = get_tree().get_first_node_in_group("hud")

	# selected_index: 0 = Sí, 1 = No
	if selected_index == 0:
		# ---- INTENTAR CURAR ----
		if not GameState.can_use_heal():
			if hud:
				var lines: Array[String] = [
					"Buscas algo para ayudarla…",
					"Pero no tienes curas suficientes."
					]
				hud.start_dialog(lines)
			return

		# consumir cura del jugador
		GameState.use_heal()

		# curar a la mujer
		state = WomanState.HEALED
		anim.play("healed")
		GameState.set_flag(helped_flag_id, true)

		if hud:
			hud.start_dialog(["Gracias… no sabes lo que significa para mí."])

	else:
		# ---- NO AYUDAR ----
		GameState.set_flag(not_helped_flag_id, true)

		# para no softlock, dar la llave igualmente
		if not GameState.has_key(key_id):
			GameState.add_key(key_id)
			GameState.set_flag("got_lab_key", true)

		if hud:
				var lines: Array[String] = [
					"No… no voy a ayudarte.",
					"Ves una llave cerca de ella y la recoges."
					]
				hud.start_dialog(lines)

# -------------------------
# DAÑO (balas llaman take_damage)
# -------------------------
func take_damage(_amount: int = 1) -> void:
	if state == WomanState.DEAD:
		return

	hits += 1
	if hits >= hits_to_die:
		_die()

func _die() -> void:
	state = WomanState.DEAD
	GameState.set_flag(killed_flag_id, true)

	# Para no softlock: si no tiene la llave, se la damos al morir
	if not GameState.has_key(key_id):
		GameState.add_key(key_id)
		GameState.set_flag("got_lab_key", true)

	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_message("La has matado. Encuentras una llave en el suelo.")

	queue_free()

# -------------------------
# Area de interacción
# -------------------------
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.show_message("Pulsa E para interactuar")

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false
