extends CharacterBody2D

@export var speed := 200.0
@export var run_multiplier := 1.5

var can_move := true

func _physics_process(delta):
	if not can_move:
		velocity = Vector2.ZERO
		return
	
	var input := Vector2.ZERO	
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	var current_speed := speed
	if Input.is_action_pressed("run"): 
		current_speed = speed * run_multiplier

	velocity = input.normalized() * current_speed
	move_and_slide()

# ============================
#   SISTEMA DE VIDA
# ============================
func take_damage(amount: int) -> void:
	GameState.damage_player(amount)
	
	var hud = get_parent().get_node_or_null("HUD")
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

# ============================
#   RECOGER OBJETOS
# ============================
func _on_item_key_body_entered(body):
	if body.name == "Player":
		var hud = get_parent().get_node("HUD")
		hud.show_message("¡Has recogido el arma!")
		get_parent().get_node("ItemKey").queue_free() # desaparece del mapa
