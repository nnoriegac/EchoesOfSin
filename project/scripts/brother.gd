extends CharacterBody2D

@export var damage: int = 30
@export var speed_charge: float = 180.0
@export var speed_exit: float = 220.0

@export var exit_marker_path: NodePath   # Marker2D al final del pasillo
@export var trigger_area_path: NodePath  # Area2D para detectar al player

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var player: Node = null
var state := "POINT"   # POINT | CHARGE | EXIT
var hit_done := false

# Flags
const FLAG_DONE := "brother_event_done"
const FLAG_WAIT := "brother_waiting"
const FLAG_ENTERED_SAVE := "entered_save_room_once"

func _ready() -> void:
	# 1. Solo aparece si la luz está encendida
	if not GameState.power_on:
		queue_free()
		return

	# 2. Si el evento ya terminó, no existe
	if GameState.has_flag(FLAG_DONE):
		queue_free()
		return

	# 3. Si el jugador ya entró a la save room y vuelve → desaparecer
	if GameState.has_flag(FLAG_WAIT) and GameState.has_flag(FLAG_ENTERED_SAVE):
		GameState.set_flag(FLAG_DONE)
		queue_free()
		return

	# Arranca señalando
	state = "POINT"
	anim.play("point")
	GameState.set_flag(FLAG_WAIT)

	# Trigger
	var trigger: Area2D = get_node(trigger_area_path)
	trigger.body_entered.connect(_on_trigger_entered)
	trigger.body_exited.connect(_on_trigger_exited)

func _physics_process(delta: float) -> void:
	match state:
		"POINT":
			# Espera. Si el jugador dispara → carga
			if _player_attacked():
				GameState.mark_optional_violence("attacked_brother")
				state = "CHARGE"
				anim.play("walk")
				hit_done = false

		"CHARGE":
			if player == null:
				return

			var dir : Vector2 = (player.global_position - global_position).normalized()
			velocity = dir * speed_charge
			move_and_slide()

			# Impacto (una sola vez)
			if not hit_done and global_position.distance_to(player.global_position) < 18:
				hit_done = true
				player.take_damage(damage)
				state = "EXIT"
				anim.play("walk")

		"EXIT":
			var exit_marker: Node2D = get_node(exit_marker_path)
			var dir2 := (exit_marker.global_position - global_position).normalized()
			velocity = dir2 * speed_exit
			move_and_slide()

			if global_position.distance_to(exit_marker.global_position) < 10:
				GameState.set_flag(FLAG_DONE)
				queue_free()

# --------------------
# DETECCIÓN PLAYER
# --------------------
func _on_trigger_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player = body

func _on_trigger_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player = null

# --------------------
# ATAQUE DEL PLAYER
# --------------------
func _player_attacked() -> bool:
	if not Input.is_action_just_pressed("shoot"):
		return false

	# ¿Tiene arma?
	if not player.has_weapon:
		return false

	# ¿Tiene munición?
	if GameState.ammo <= 0:
		return false

	return true
