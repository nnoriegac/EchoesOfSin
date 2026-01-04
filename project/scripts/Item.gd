extends Area2D

@export var item_id: String = ""     # nombre del item: "key_lab", "cura", "ammo", etc.
@export var is_key: bool = false     # si es una llave
@export var heal_amount: int = 0     # curación
@export var ammo_amount: int = 0     # munición
@export var gives_weapon: bool = false  # si es un arma

@export var sprite_anim: StringName = &""   # nombre de animación en SpriteFrames

var player_in_range := false
var player_ref: Node = null

@onready var anim := $AnimatedSprite2D

func _on_body_entered(body: Node) -> void:
	if body.name != "Player":
		return
	
	player_in_range = true
	player_ref = body
	
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_message("Pulsa E para recoger")

func _on_body_exited(body: Node) -> void:
	if body.name != "Player":
		return
	player_in_range = false
	player_ref = null

func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		_pickup()

func _pickup() -> void:
	# LLAVE
	if is_key:
		GameState.add_key(item_id)
	
	# CURA
	if heal_amount > 0:
		GameState.add_heals(heal_amount) # heal_amount = nº de curas que da el objeto
	
	# MUNICIÓN
	if ammo_amount > 0:
		GameState.add_ammo(ammo_amount)
	
	# ARMA
	if gives_weapon:
		GameState.add_item(item_id)
		if player_ref and player_ref.has_method("unlock_weapon"):
			player_ref.unlock_weapon(item_id)
	
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_pickup_dialog("Has recogido " + item_id)

	# Eliminar el objeto del mapa
	queue_free()

func _ready() -> void:
	# Si es una llave y ya la tiene el jugador, no mostramos el item
	if is_key and GameState.has_key(item_id):
		queue_free()
		return
	
	# Poner animación/imagen
	if sprite_anim != &"" and anim.sprite_frames and anim.sprite_frames.has_animation(sprite_anim):
		anim.play(sprite_anim)
	else:
		anim.stop()
