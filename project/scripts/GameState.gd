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
var weapon_ids: Array[String] = ["weapon_CountersRoom", "un arma."]

var power_on: bool = false

var dead_enemies: Dictionary = {}
var opened_doors: Dictionary = {}  
var flags: Dictionary = {}  

func _ready() -> void:
	#  para comprobar que el autoload funciona.
	print("GameState listo. Vida:", player_hp, " / ", player_hp_max)
	
	# Emit inicial para que el HUD se pinte bien si arranca después
	emit_signal("hp_changed", player_hp, player_hp_max)
	emit_signal("ammo_changed", ammo, ammo_max)
	emit_signal("heals_changed", heals)

# -----------------------
# PUERTAS
# -----------------------
func set_door_opened(id: String) -> void:
	opened_doors[id] = true

func is_door_opened(id: String) -> bool:
	return opened_doors.has(id)

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

func player_has_weapon() -> bool:
	return has_item("weapon_CountersRoom") or has_item("un arma.")

func has_any_weapon() -> bool:
	for wid in weapon_ids:
		if has_item(wid):
			return true
	return false
# -----------------------
# Guardar partida
# -----------------------
func save_game() -> void:
	var data = {
		"keys": keys,
		"ammo": ammo,
		"player_hp": player_hp,
		"heals": heals,
		"opened_doors": opened_doors,
		"flags": flags,
		"current_scene": get_tree().current_scene.scene_file_path
	}

	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_game() -> void:
	if not FileAccess.file_exists("user://savegame.json"):
		return

	var f = FileAccess.open("user://savegame.json", FileAccess.READ)
	var data = JSON.parse_string(f.get_as_text())
	f.close()

	dead_enemies = data.get("dead_enemies", {})
	opened_doors = data.get("opened_doors", {})
	flags = data.get("flags", {})

# -----------------------
# EVENTOS
# -----------------------
func set_flag(id: String, value: bool = true) -> void:
	flags[id] = value

func has_flag(id: String) -> bool:
	return flags.get(id, false)

func mark_optional_violence(flag_id: String = "") -> void:
	set_flag("optional_violence_used", true)
	if flag_id != "":
		set_flag(flag_id, true)
