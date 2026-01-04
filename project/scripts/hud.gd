extends CanvasLayer

@export var message_duration := 1.0 
@onready var message_label = $Message
@onready var hp_label = $HpLabel
@onready var ammo_label = $AmmoLabel
@onready var heals_label = $HealsLabel
@onready var dialog_box = $DialogBox
@onready var dialog_text = $DialogBox/DialogText

var dialog_lines: Array[String] = []
var dialog_index: int = 0
var dialog_active: bool = false

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
	
	dialog_lines = lines
	dialog_index = 0
	dialog_active = true

	dialog_box.visible = true
	
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
		
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.can_move = true
		
	else:
		_show_current_line()

func _process(delta: float) -> void:
	if dialog_active and Input.is_action_just_pressed("ui_accept"):
		_advance_dialog()
