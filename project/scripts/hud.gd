extends CanvasLayer

@export var message_duration := 1.0 
@onready var message_label = $Message
@onready var hp_label = $HpLabel
@onready var ammo_label = $AmmoLabel
@onready var heals_label = $HealsLabel
@onready var dialog_box = $DialogBox
@onready var dialog_text = $DialogBox/DialogText
@onready var flash_rect: ColorRect = $FlashRect

var dialog_lines: Array[String] = []
var dialog_index: int = 0
var dialog_active: bool = false
signal dialog_started
signal dialog_finished

var choice_active: bool = false
var choice_index: int = 0
var choice_question: String = ""
var choice_options: Array[String] = []
var choice_callback: Callable = Callable()

func _ready() -> void:
	message_label.visible = false
	dialog_box.visible = false

	update_hp(GameState.player_hp, GameState.player_hp_max)
	update_ammo(GameState.ammo, GameState.ammo_max)
	update_heals(GameState.heals)
	
	# Conectar signals para que se actualice al momento
	GameState.hp_changed.connect(update_hp)
	GameState.ammo_changed.connect(update_ammo)
	GameState.heals_changed.connect(update_heals)

func show_message(text: String) -> void:
	message_label.text = text
	message_label.visible = true
	await get_tree().create_timer(message_duration).timeout
	message_label.visible = false

# muestre mensaje cuando recoges item
func show_pickup_dialog(text: String) -> void:
	start_dialog([text])

# ---------- VIDA Y MUNICIÓN ----------
func update_hp(current: int, max_hp: int) -> void:
	hp_label.text = "Vida: %d/%d" % [current, max_hp]

func update_ammo(current: int, max_ammo: int) -> void:
	ammo_label.text = "Munición: %d/%d" % [current, max_ammo]

func update_heals(count: int) -> void:
	heals_label.text = "Curas: %d" % count

# ---------- DIÁLOGOS ----------
func start_dialog(lines: Array[String]) -> void:
	if lines.is_empty():
		return
	
	# Si hay choice activo, no mezclar sistemas
	if choice_active:
		return
	
	dialog_lines = lines
	dialog_index = 0
	dialog_active = true

	dialog_box.visible = true
	emit_signal("dialog_started")
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = false
	
	_show_current_line()

func _show_current_line() -> void:
	dialog_text.text = dialog_lines[dialog_index]

func _advance_dialog() -> void:
	dialog_index += 1
	if dialog_index >= dialog_lines.size():
		dialog_active = false
		dialog_box.visible = false
		emit_signal("dialog_finished")
		
		var tree := get_tree()
		if tree:
			var player = tree.get_first_node_in_group("player")
			if player and "can_move" in player:
				player.can_move = true
	
	else:
		_show_current_line()

# ---------- CHOICE (Sí/No, etc.) ----------
func start_choice(question: String, options: Array, callback: Callable) -> void:
	if options.size() < 2:
		return

	# Si hay diálogo activo, no mezclar
	if dialog_active:
		return

	choice_active = true
	choice_index = 0
	choice_question = question
	
	choice_options.clear()
	for o in options:
		choice_options.append(str(o))
		
	choice_callback = callback

	dialog_box.visible = true

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = false

	_render_choice()

func _render_choice() -> void:
	# Ej: "> Sí   No"
	var line := ""
	for i in range(choice_options.size()):
		if i == choice_index:
			line += "> " + choice_options[i] + "   "
		else:
			line += "  " + choice_options[i] + "   "
	dialog_text.text = choice_question + "\n" + line.strip_edges()

func _confirm_choice() -> void:
	var selected := choice_index
	var selected_text := choice_options[choice_index]

	# cerrar UI antes de ejecutar callback (evita bugs si el callback abre otros diálogos)
	choice_active = false
	dialog_box.visible = false

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = true

	if choice_callback.is_valid():
		choice_callback.call(selected, selected_text)

func _cancel_choice() -> void:
	choice_active = false
	dialog_box.visible = false

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = true

func _process(delta: float) -> void:
	# CHOICE tiene prioridad sobre diálogo normal
	if choice_active:
		if Input.is_action_just_pressed("ui_left"):
			choice_index = max(choice_index - 1, 0)
			_render_choice()
		elif Input.is_action_just_pressed("ui_right"):
			choice_index = min(choice_index + 1, choice_options.size() - 1)
			_render_choice()
		elif Input.is_action_just_pressed("ui_accept"):
			_confirm_choice()
		elif Input.is_action_just_pressed("ui_cancel"):
			_cancel_choice()
		return
	
	# diálogo normal
	if dialog_active and Input.is_action_just_pressed("ui_accept"):
		_advance_dialog()

func flash(duration: float = 0.12, times: int = 2) -> void:
	flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_rect.visible = true
	flash_rect.modulate.a = 0.0

	for i in range(times):
		var t1 := create_tween()
		t1.tween_property(flash_rect, "modulate:a", 1.0, duration)
		await t1.finished

		var t2 := create_tween()
		t2.tween_property(flash_rect, "modulate:a", 0.0, duration)
		await t2.finished

	flash_rect.visible = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
