extends CharacterBody2D

@export var speed := 200.0
@export var run_multiplier := 1.5

@export var attack_damage: int = 20

@export var shoot_anim_time := 0.35 # duración “flash” de anim con arma

var bullet_scene := preload("res://scenes/Bullet.tscn")

var can_move := true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Última dirección para idle
var last_move_dir := Vector2.DOWN
# Última dirección para ataque
var last_shoot_dir := Vector2.RIGHT

var shooting := false
var shooting_timer := 0.0

func _physics_process(delta):
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# --- MOVIMIENTO ---
	var input := Vector2.ZERO	
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	var current_speed := speed
	if Input.is_action_pressed("run"): 
		current_speed = speed * run_multiplier
		
	if input != Vector2.ZERO:
		var move_dir := input.normalized()
		velocity = move_dir * current_speed
		move_and_slide()
		
		# Guardamos última dirección y animamos walk
		last_move_dir = _dir_to_4way(move_dir)
	else:
		velocity = Vector2.ZERO
		move_and_slide()

	# --- ATAQUE / DISPARO ---
	if Input.is_action_just_pressed("shoot"):
		# Calcula dirección real de la bala (ratón)
		var dir = (get_global_mouse_position() - global_position)
		
		if dir.length() == 0:
			dir = Vector2.RIGHT
		last_shoot_dir = _dir_to_4way(dir)
		
		_start_shoot_anim()
		shoot() 
	
	# --- ACTUALIZAR TEMPORIZADOR DE SHOOT ---
	if shooting:
		shooting_timer -= delta
		if shooting_timer <= 0.0:
			shooting = false

	# --- ANIMACIÓN FINAL (prioridad: shoot > walk > idle) ---
	_update_animation(input)

# ============================
#   ANIMACIÓN (idle/walk/attack)
# ============================

func _play_walk(d: Vector2) -> void:
	var anim := _anim_name("walk", d)
	if sprite.animation != anim or !sprite.is_playing():
		sprite.play(anim)

func _play_idle(d: Vector2) -> void:
	var anim := _anim_name("idle", d)
	if sprite.animation != anim:
		sprite.play(anim)

func _start_shoot_anim() -> void:
	shooting = true
	shooting_timer = shoot_anim_time
	# NO bloqueamos movimiento

func _update_animation(input: Vector2) -> void:
	# 1) Si estamos en ventana de disparo: animación con arma según dirección de disparo
	if shooting:
		var anim := _anim_name("attack", last_shoot_dir)
		# Evita reiniciar si ya está
		if sprite.animation != anim:
			sprite.play(anim)
		return

	# 2) Si se mueve: caminar según dirección de movimiento
	if input != Vector2.ZERO:
		var anim := _anim_name("walk", last_move_dir)
		if sprite.animation != anim:
			sprite.play(anim)
		return

	# 3) Si está quieto: idle según última dirección de movimiento
	var idle_anim := _anim_name("idle", last_move_dir)
	if sprite.animation != idle_anim:
		sprite.play(idle_anim)

func _dir_to_4way(d: Vector2) -> Vector2:
	# Convertimos vector a una de 4 direcciones
	if d == Vector2.ZERO:
		return Vector2.DOWN
	if abs(d.x) > abs(d.y):
		return Vector2.RIGHT if d.x > 0 else Vector2.LEFT
	else:
		return Vector2.DOWN if d.y > 0 else Vector2.UP

func _anim_name(prefix: String, d: Vector2) -> String:
	if d == Vector2.DOWN:
		return prefix + "_down"
	if d == Vector2.UP:
		return prefix + "_up"
	if d == Vector2.LEFT:
		return prefix + "_left"
	return prefix + "_right"
	
# ============================
#   SISTEMA DE VIDA
# ============================
func take_damage(amount: int) -> void:
	GameState.damage_player(amount)
	
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_hp(GameState.player_hp, GameState.player_hp_max)
	
	if GameState.player_hp <= 0:
		die()

func die() -> void:
	# bloquear movimiento del jugador
	can_move = false
	
	# instanciar pantalla de muerte
	var death_screen = preload("res://scenes/DeathScreen.tscn").instantiate()
	get_tree().current_scene.add_child(death_screen)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("use_heal"):
		var used : bool = GameState.use_heal()
		if used:
			var hud = get_tree().get_first_node_in_group("hud")
			if hud:
				hud.show_message("Te has curado +%d" % GameState.heal_value)

# ============================
#   RECOGER OBJETOS
# ============================
func unlock_weapon(weapon_id: String):
	print("Arma obtenida:", weapon_id)
	GameState.add_item(weapon_id)
	# Más adelante aquí activo disparo, o cambiar modo de ataque ...

# ============================
#   DISPARAR
# ============================
func shoot() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	# ¿Hay munición?
	if not GameState.spend_ammo(1):
		if hud:
			hud.show_message("No te queda munición...")
		return
	
	# Crear la bala
	var bullet = bullet_scene.instantiate()
	
	# Posición inicial de la bala (en el jugador)
	bullet.global_position = global_position
	
	# Dirección de disparo: hacia el ratón (simple y efectivo)
	var dir = (get_global_mouse_position() - global_position)
	if dir.length() == 0:
		dir = Vector2.RIGHT
	bullet.direction = dir.normalized()
	
	# Añadir la bala a la escena actual
	get_tree().current_scene.add_child(bullet)
	
	# Actualizar HUD de munición
	if hud:
		hud.update_ammo(GameState.ammo, GameState.ammo_max)
