extends CharacterBody2D

enum {
	STATE_PATROL,
	STATE_CHASE
}

@export var speed: float = 180.0
@export var detection_radius: float = 500.0
@export var attack_radius: float = 100.0
@export var damage: int = 10
@export var attack_cooldown: float = 1.0

@export var max_hp: int = 50
@export var patrol_distance: float = 500.0   # hasta dónde se aleja a izquierda/derecha
var hp: int

var state: int = STATE_PATROL

var left_point: Vector2
var right_point: Vector2
var going_right: bool = true

var player: Node = null
var attack_timer: float = 0.0

func _ready() -> void:
	print("Enemy READY en: ", global_position)
	hp = max_hp

# puntos de patrulla fijos en el mundo, a partir de donde nace el enemigo
	left_point = global_position + Vector2(-patrol_distance, 0)
	right_point = global_position + Vector2(patrol_distance, 0)

	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return
	
	attack_timer -= delta
	
	match state:
		STATE_PATROL:
			_process_patrol(delta)
		STATE_CHASE:
			_process_chase(delta)
	
	move_and_slide()
	
	_update_state()

func _process_patrol(delta: float) -> void:
	var target_pos := right_point if going_right else left_point
	var dir := (target_pos - global_position)
	
	if dir.length() < 4.0:
		going_right = not going_right
	
	velocity = dir.normalized() * speed


func _process_chase(delta: float) -> void:
	var dir : Vector2 = (player.global_position - global_position)
	var dist := dir.length()
	
	if dist > 0.0:
		velocity = dir.normalized() * speed
	
	# ataque si está muy cerca
	if dist <= attack_radius and attack_timer <= 0.0:
		attack_player()
		attack_timer = attack_cooldown

func _update_state() -> void:
	var dist_to_player : float = (player.global_position - global_position).length()
	
	if dist_to_player <= detection_radius:
		state = STATE_CHASE
	else:
		state = STATE_PATROL

func attack_player() -> void:
	if player == null:
		return
	
	if player.has_method("take_damage"):
		player.take_damage(damage)

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		die()


func die() -> void:
	print("Enemy DIE")
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_pickup_dialog("Has derrotado al enemigo.")
	
	queue_free()
