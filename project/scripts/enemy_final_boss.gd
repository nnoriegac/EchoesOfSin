extends CharacterBody2D
signal died

@export var speed: float = 200.0
@export var detection_radius: float = 800.0
@export var attack_radius: float = 110.0
@export var damage: int = 15
@export var attack_cooldown: float = 0.9
@export var max_hp: int = 120

@onready var sprite: AnimatedSprite2D = $Sprite2D

var hp: int
var player: Node = null
var attack_timer: float = 0.0
var is_attacking := false

func _ready() -> void:
	hp = max_hp
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return

	attack_timer -= delta

	var dir :Vector2= (player.global_position - global_position)
	var dist := dir.length()

	# Persigue siempre si lo “huele” (no se pacifica nunca)
	if dist <= detection_radius:
		var move_dir := dir.normalized()
		velocity = move_dir * speed

		if not is_attacking:
			var anim := _anim_name("walk", _dir_to_4way(move_dir))
			if sprite.animation != anim:
				sprite.play(anim)
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	if dist <= attack_radius and attack_timer <= 0.0:
		attack_player(dir)

func attack_player(dir: Vector2) -> void:
	if player == null:
		return
	is_attacking = true
	attack_timer = attack_cooldown

	var attack_dir := _dir_to_4way(dir)
	sprite.play(_anim_name("attack", attack_dir))

	if player.has_method("take_damage"):
		player.take_damage(damage)

	await get_tree().create_timer(0.25).timeout
	is_attacking = false

func take_damage(amount: int) -> void:
	# Cuenta como violencia
	GameState.mark_optional_violence("attacked_final_boss")
	hp -= amount
	if hp <= 0:
		die()

func force_die() -> void:
	die()

func die() -> void:
	emit_signal("died")
	queue_free()

func _dir_to_4way(d: Vector2) -> Vector2:
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
