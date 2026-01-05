extends Node

@export var boss_path: NodePath
@export var brother_path: NodePath
@export var brother_spawn_marker_path: NodePath
@export var good_trigger_path: NodePath

@export var end_scene_good: PackedScene
@export var end_scene_bad: PackedScene

var boss: Node = null
var brother: Node = null
var marker: Node2D = null
var trigger: Area2D = null

var ending_running := false

func _ready() -> void:
	boss = get_node_or_null(boss_path)
	brother = get_node_or_null(brother_path)
	marker = get_node_or_null(brother_spawn_marker_path)
	trigger = get_node_or_null(good_trigger_path)

	# Oculta hermano (por si acaso)
	if brother:
		brother.visible = false
		brother.process_mode = Node.PROCESS_MODE_DISABLED

	# Conecta muerte del boss (final malo)
	if boss and boss.has_signal("died"):
		boss.died.connect(_on_boss_died)

	# Conecta trigger (final bueno)
	if trigger:
		trigger.body_entered.connect(_on_good_trigger_entered)

func _on_good_trigger_entered(body: Node) -> void:
	if ending_running:
		return
	if not body.is_in_group("player"):
		return

	# Solo final bueno si NO hubo violencia
	if not GameState.has_flag("optional_violence_used"):
		await _good_ending_sequence()

func _on_boss_died() -> void:
	if ending_running:
		return

	# Si hubo violencia: al matar al boss → castigo
	if GameState.has_flag("optional_violence_used"):
		await _bad_ending_sequence()
	else:
		# Por si el jugador lo mata igual sin violencia (raro): da bueno igualmente
		await _good_ending_sequence()

func _good_ending_sequence() -> void:
	ending_running = true
	var hud = get_tree().get_first_node_in_group("hud")
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = false

	if hud and hud.has_method("flash"):
		await hud.flash(0.10, 2)

	_spawn_brother()

	# Mata al boss de golpe
	if boss and is_instance_valid(boss):
		if boss.has_method("force_die"):
			boss.force_die()
		else:
			boss.queue_free()

	if hud:
		hud.start_dialog([
			"Hermano…",
			"Creí que ya no quedaba nada de ti.",
			"Despertaste sin recuerdos, y aun así elegiste no repetir lo que fuiste.",
			"Quizá perder la memoria fue tu oportunidad para enfrentarte a tus pecados… y no huir de ellos.",
			"Quedémonos aquí.",
			"Vivamos tranquilos.",
			"Deja atrás tus antiguas hazañas. Nadie más debe sufrir por nuestra culpa."
		]as Array[String])
		await hud.dialog_finished

	_end_good()

func _bad_ending_sequence() -> void:
	ending_running = true
	var hud = get_tree().get_first_node_in_group("hud")
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = false

	if hud and hud.has_method("flash"):
		await hud.flash(0.10, 2)

	_spawn_brother()

	# A 1 de vida
	if GameState.has_method("force_set_hp"):
		GameState.force_set_hp(1)
	else:
		GameState.player_hp = 1
		GameState.emit_signal("hp_changed", GameState.player_hp, GameState.player_hp_max)

	if hud:
		hud.start_dialog([
			"Hermano…",
			"Te di una oportunidad.",
			"Despertaste sin recuerdos, libre de tus pecados… y aun así elegiste volver a ellos.",
			"No respetaste la vida de este lugar.",
			"Fuimos ratas de laboratorio para ti.",
			"No me pidas perdón.",
			"Ya tomaste tu decisión."
		]as Array[String])
		await hud.dialog_finished

	if hud and hud.has_method("flash"):
		await hud.flash(0.08, 1)

	# Muerte forzada
	if GameState.has_method("force_set_hp"):
		GameState.force_set_hp(0)
	else:
		GameState.player_hp = 0
		GameState.emit_signal("hp_changed", GameState.player_hp, GameState.player_hp_max)

	if player and player.has_method("die"):
		player.die()

	_end_bad()

func _spawn_brother() -> void:
	if not brother:
		return

	var pos := Vector2.ZERO
	if marker:
		pos = marker.global_position
	else:
		# fallback: cerca del player
		var player = get_tree().get_first_node_in_group("player")
		if player:
			pos = player.global_position + Vector2(80, 0)

	if brother.has_method("appear_at"):
		brother.appear_at(pos)
	else:
		brother.global_position = pos
		brother.visible = true
		brother.process_mode = Node.PROCESS_MODE_INHERIT

func _end_good() -> void:
	if end_scene_good:
		get_tree().change_scene_to_packed(end_scene_good)
		return
	# Si no tienes escena final, por ahora recarga o deja en negro
	print("FIN BUENO")

func _end_bad() -> void:
	if end_scene_bad:
		get_tree().change_scene_to_packed(end_scene_bad)
		return
	print("FIN MALO")
