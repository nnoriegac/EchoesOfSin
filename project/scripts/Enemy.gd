extends CharacterBody2D

enum {
	STATE_PATROL,
	STATE_CHASE
}
@export var world_id: String = "enemy_livingroom"  

@export var speed: float = 180.0
@export var detection_radius: float = 500.0
@export var attack_radius: float = 100.0
@export var damage: int = 10
@export var attack_cooldown: float = 1.0

@export var max_hp: int = 50
@export var patrol_distance: float = 500.0   # hasta dónde se aleja a izquierda/derecha

@export var attacked_flag_id: String = "attacked_enemy_livingroom"
@export var counts_for_optional_violence: bool = true
@export var pacified_flag_id: String = "pacified_enemy_livingroom"  # único por enemigo
var pacified: bool = false

@export var lose_interest_time: float = 6.0
@export var reaggro_cooldown: float = 3.0
var chase_time := 0.0
var reaggro_timer := 0.0



@onready var sprite: AnimatedSprite2D = $Sprite2D
var is_attacking := false

var hp: int

var state: int = STATE_PATROL

var left_point: Vector2
var right_point: Vector2
var going_right: bool = true

var player: Node = null
var attack_timer: float = 0.0

func _ready() -> void:
	if world_id != "" and GameState.dead_enemies.has(world_id):
		queue_free()
		return
	
	pacified = GameState.has_flag(pacified_flag_id)
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
	reaggro_timer = max(reaggro_timer - delta, 0.0)
	
	if pacified:
		# solo patrulla, nunca chase
		state = STATE_PATROL
		_process_patrol(delta)
		move_and_slide()
		return
	
	match state:
		STATE_PATROL:
			_process_patrol(delta)
		STATE_CHASE:
			chase_time += delta
			
			if not GameState.has_flag(attacked_flag_id) and chase_time >= lose_interest_time:
				pacified = true
				GameState.set_flag(pacified_flag_id, true)  # se guarda
				state = STATE_PATROL
				chase_time = 0.0
				velocity = Vector2.ZERO
				return
			_process_chase(delta)
	
	move_and_slide()
	
	_update_state()

func _process_patrol(delta: float) -> void:
	var target_pos := right_point if going_right else left_point
	var dir := (target_pos - global_position)

	if dir.length() < 4.0:
		going_right = not going_right

	var move_dir := dir.normalized()
	velocity = move_dir * speed

	if not is_attacking:
		var anim_name := _anim_name("walk", _dir_to_4way(move_dir))
		if sprite.animation != anim_name:
			sprite.play(anim_name)

func _process_chase(delta: float) -> void:
	var dir: Vector2 = (player.global_position - global_position)
	var dist := dir.length()

	if dist > 0.0:
		var move_dir := dir.normalized()
		velocity = move_dir * speed

		if not is_attacking:
			var anim := _anim_name("walk", _dir_to_4way(move_dir))
			if sprite.animation != anim:
				sprite.play(anim)

	# ataque si está muy cerca
	if dist <= attack_radius and attack_timer <= 0.0:
		attack_player(dir)

func _update_state() -> void:
	if pacified:
		state = STATE_PATROL
		return

	if reaggro_timer > 0.0:
		state = STATE_PATROL
		return
	
	var dist_to_player : float = (player.global_position - global_position).length()
	
	if dist_to_player <= detection_radius:
		state = STATE_CHASE
	else:
		state = STATE_PATROL
		chase_time = 0.0

func attack_player(dir: Vector2) -> void:
	if player == null:
		return

	is_attacking = true
	attack_timer = attack_cooldown

	var attack_dir := _dir_to_4way(dir)
	var anim := _anim_name("attack", attack_dir)
	sprite.play(anim)

	if player.has_method("take_damage"):
		player.take_damage(damage)

	# volver a caminar tras un pequeño delay
	await get_tree().create_timer(0.25).timeout
	is_attacking = false

func take_damage(amount: int) -> void:
	# si estaba pacificado, al atacarlo se “activa”
	pacified = false
	GameState.set_flag(pacified_flag_id, false)
	
	if counts_for_optional_violence:
		GameState.mark_optional_violence(attacked_flag_id)
	
	hp -= amount
	if hp <= 0:
		die()


func die() -> void:
	print("Enemy DIE")
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_pickup_dialog("Has derrotado al enemigo.")
	
	if world_id != "":
		GameState.dead_enemies[world_id] = true
	queue_free()

func _dir_to_4way(d: Vector2) -> Vector2:
	# Convertimos vector a una de 4 direcciones
	if d == Vector2.ZERO:
		return Vector2.DOWN
	if abs(d.x) > abs(d.y):
		return Vector2.RIGHT if d.x > 0 else Vector2.LEFT
	else:
		return Vector2.DOWN if d.y > 0 else Vector2.UP

func _anim_name(prefix: String, d: Vector2) -> String:
	if d == Vector2.UP:
		return prefix + "_up"
	if d == Vector2.DOWN:
		return prefix + "_down"
	if d == Vector2.LEFT:
		return prefix + "_left"
	return prefix + "_right"
