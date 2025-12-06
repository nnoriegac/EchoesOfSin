extends Node


var player_hp_max: int = 100
var player_hp: int = player_hp_max

var ammo_max: int = 10
var ammo: int = 0

var inventory: Array[String] = []
var keys: Array[String] = []

var power_on: bool = false

func _ready() -> void:
	#  para comprobar que el autoload funciona.
	print("GameState listo. Vida:", player_hp, " / ", player_hp_max)


func damage_player(amount: int) -> void:
	player_hp -= amount
	if player_hp < 0:
		player_hp = 0

func heal_player(amount: int) -> void:
	player_hp += amount
	if player_hp > player_hp_max:
		player_hp = player_hp_max

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

func add_ammo(amount: int) -> void:
	ammo += amount
	if ammo > ammo_max:
		ammo = ammo_max

func spend_ammo(amount: int = 1) -> bool:
	if ammo >= amount:
		ammo -= amount
		return true
	return false
