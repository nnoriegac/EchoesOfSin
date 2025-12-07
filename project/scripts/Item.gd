extends Area2D

@export var item_id: String = ""     # nombre del item: "key_lab", "cura", "ammo", etc.
@export var is_key: bool = false     # si es una llave
@export var heal_amount: int = 0     # curación
@export var ammo_amount: int = 0     # munición
@export var gives_weapon: bool = false  # si es un arma

func _on_body_entered(body):
	if body.name != "Player":
		return
	
	# LLAVE
	if is_key:
		GameState.add_key(item_id)
	
	# CURA
	if heal_amount > 0:
		GameState.heal_player(heal_amount)
	
	# MUNICIÓN
	if ammo_amount > 0:
		GameState.add_ammo(ammo_amount)
	
	# ARMA
	if gives_weapon:
		GameState.add_item(item_id)
		body.unlock_weapon(item_id) 
	
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_pickup_dialog("Has recogido " + item_id)

	# Eliminar el objeto del mapa
	queue_free()

func _ready() -> void:
	# Si es una llave y ya la tiene el jugador, no mostramos el item
	if is_key and GameState.has_key(item_id):
		queue_free()
