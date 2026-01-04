extends Node

signal hp_changed(current: int, max_hp: int)
signal ammo_changed(current: int, max_ammo: int)
signal heals_changed(count: int)

var player_hp_max: int = 100
var player_hp: int = player_hp_max

var ammo_max: int = 50
var ammo: int = 0

var heals: int = 0              # cuántas curas tienes
var heal_value: int = 10        # cuánto cura cada uso

var inventory: Array[String] = []
var keys: Array[String] = []

var power_on: bool = false

func _ready() -> void:
	#  para comprobar que el autoload funciona.
	print("GameState listo. Vida:", player_hp, " / ", player_hp_max)
	
	# Emit inicial para que el HUD se pinte bien si arranca después
	emit_signal("hp_changed", player_hp, player_hp_max)
	emit_signal("ammo_changed", ammo, ammo_max)
	emit_signal("heals_changed", heals)

# -----------------------
# VIDA
# -----------------------
func damage_player(amount: int) -> void:
	player_hp -= amount
	if player_hp < 0:
		player_hp = 0

func heal_player(amount: int) -> void:
	player_hp += amount
	if player_hp > player_hp_max:
		player_hp = player_hp_max

func can_use_heal() -> bool:
	return heals > 0 and player_hp < player_hp_max

func use_heal() -> bool:
	if heals <= 0:
		return false
	if player_hp >= player_hp_max:
		return false

	heals -= 1
	player_hp = min(player_hp + heal_value, player_hp_max)

	emit_signal("heals_changed", heals)
	emit_signal("hp_changed", player_hp, player_hp_max)
	return true

func add_heals(count: int = 1) -> void:
	heals += count
	if heals < 0:
		heals = 0
	emit_signal("heals_changed", heals)

# -----------------------
# INVENTARIO / LLAVES
# -----------------------
func add_item(item_id: String) -> void:
	if item_id not in inventory:
		inventory.append(item_id)

func has_item(item_id: String) -> bool:
	return item_id in inventory

func add_key(key_id: String) -> void:
	if key_id not in keys:
		keys.append(key_id)

func has_key(key_id: String) -> bool:
	return key_id in keys

# -----------------------
# MUNICIÓN
# -----------------------
func add_ammo(amount: int) -> void:
	var prev := ammo
	ammo = min(ammo + amount, ammo_max)
	if ammo != prev:
		emit_signal("ammo_changed", ammo, ammo_max)

func spend_ammo(amount: int = 1) -> bool:
	if ammo >= amount:
		ammo -= amount
		emit_signal("ammo_changed", ammo, ammo_max)
		return true
	return false
