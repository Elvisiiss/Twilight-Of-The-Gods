extends Node

enum PKMode {
	PEACE,
	FREE,
	GUILD,
	TEAM
}

var player_pk_data: Dictionary = {}
var pk_zones: Dictionary = {}
var kill_counts: Dictionary = {}

func _ready():
	initialize_pk_zones()

func initialize_pk_zones():
	pk_zones = {
		"god_realm": {
			"name": "神界",
			"pk_mode": PKMode.FREE,
			"is_safe": false
		},
		"dragon_cave": {
			"name": "龙穴",
			"pk_mode": PKMode.FREE,
			"is_safe": false
		},
		"dark_forest": {
			"name": "黑暗森林",
			"pk_mode": PKMode.GUILD,
			"is_safe": false
		},
		"start_village": {
			"name": "新手村",
			"pk_mode": PKMode.PEACE,
			"is_safe": true
		}
	}

func set_pk_mode(player: Node, mode: PKMode):
	var key: String = str(player.get_path())
	
	if key not in player_pk_data:
		player_pk_data[key] = {
			"pk_mode": mode,
			"is_red_name": false,
			"kill_count": 0,
			"death_count": 0,
			"last_kill_time": 0,
			"protection_time": 0
		}
	else:
		player_pk_data[key]["pk_mode"] = mode

func get_pk_mode(player: Node) -> PKMode:
	var key: String = str(player.get_path())
	return player_pk_data.get(key, {}).get("pk_mode", PKMode.PEACE)

func is_red_name(player: Node) -> bool:
	var key: String = str(player.get_path())
	return player_pk_data.get(key, {}).get("is_red_name", false)

func get_kill_count(player: Node) -> int:
	var key: String = str(player.get_path())
	return player_pk_data.get(key, {}).get("kill_count", 0)

func get_death_count(player: Node) -> int:
	var key: String = str(player.get_path())
	return player_pk_data.get(key, {}).get("death_count", 0)

func on_player_kill(killer: Node, victim: Node):
	if not is_pk_allowed(killer, victim):
		return
	
	var killer_key: String = str(killer.get_path())
	var victim_key: String = str(victim.get_path())
	
	if killer_key not in player_pk_data:
		player_pk_data[killer_key] = {"pk_mode": PKMode.FREE, "is_red_name": false, "kill_count": 0, "death_count": 0, "last_kill_time": 0, "protection_time": 0}
	
	if victim_key not in player_pk_data:
		player_pk_data[victim_key] = {"pk_mode": PKMode.FREE, "is_red_name": false, "kill_count": 0, "death_count": 0, "last_kill_time": 0, "protection_time": 0}
	
	player_pk_data[killer_key]["kill_count"] += 1
	player_pk_data[killer_key]["last_kill_time"] = OS.get_ticks_msec()
	
	player_pk_data[victim_key]["death_count"] += 1
	
	if not is_red_name(killer):
		check_red_name(killer)
	
	EventBus.emit_pk_kill(killer, victim)

func check_red_name(player: Node):
	var key: String = str(player.get_path())
	
	if player_pk_data[key]["kill_count"] >= 3:
		player_pk_data[key]["is_red_name"] = true
		EventBus.emit_red_name(player)

func is_pk_allowed(attacker: Node, target: Node) -> bool:
	var map_manager: MapManager = get_node_or_null("/root/MapManager")
	if not map_manager:
		return false
	
	var current_map: String = map_manager.current_map
	var zone: Dictionary = pk_zones.get(current_map, {})
	
	if zone.get("is_safe", false):
		return false
	
	var attacker_mode: PKMode = get_pk_mode(attacker)
	var target_mode: PKMode = get_pk_mode(target)
	
	match zone.get("pk_mode", PKMode.PEACE):
		PKMode.PEACE:
			return false
		PKMode.FREE:
			return true
		PKMode.GUILD:
			return check_guild_pk(attacker, target)
		PKMode.TEAM:
			return check_team_pk(attacker, target)
	
	return false

func check_guild_pk(attacker: Node, target: Node) -> bool:
	var guild_system: GuildSystem = get_node_or_null("/root/GuildSystem")
	if not guild_system:
		return false
	
	var attacker_guild: Dictionary = guild_system.get_guild(attacker)
	var target_guild: Dictionary = guild_system.get_guild(target)
	
	if not attacker_guild or not target_guild:
		return false
	
	return attacker_guild["id"] != target_guild["id"]

func check_team_pk(attacker: Node, target: Node) -> bool:
	return true

func reset_pk_data(player: Node):
	var key: String = str(player.get_path())
	if key in player_pk_data:
		player_pk_data.erase(key)
