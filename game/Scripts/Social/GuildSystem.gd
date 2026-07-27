extends Node

var guilds: Dictionary = {}
var player_guilds: Dictionary = {}

func _ready():
	pass

func create_guild(player: Node, name: String, emblem: String = "") -> bool:
	if player in player_guilds:
		return false
	
	var guild_id: String = name.lower().replace(" ", "_") + "_" + str(OS.get_ticks_msec())
	
	guilds[guild_id] = {
		"id": guild_id,
		"name": name,
		"emblem": emblem,
		"level": 1,
		"experience": 0,
		"members": [player],
		"roles": {
			"leader": {"name": "会长", "permissions": ["all"]},
			"officer": {"name": "副会长", "permissions": ["invite", "kick", "manage"]},
			"member": {"name": "成员", "permissions": ["chat"]}
		},
		"member_roles": {str(player.get_path()): "leader"},
		"chat_history": [],
		"created_at": OS.get_ticks_msec()
	}
	
	player_guilds[player] = guild_id
	
	EventBus.emit_guild_create(guild_id)
	return true

func join_guild(player: Node, guild_id: String) -> bool:
	if player in player_guilds:
		return false
	
	if guild_id not in guilds:
		return false
	
	var guild: Dictionary = guilds[guild_id]
	
	if len(guild["members"]) >= get_max_members(guild["level"]):
		return false
	
	guild["members"].append(player)
	guild["member_roles"][str(player.get_path())] = "member"
	player_guilds[player] = guild_id
	
	EventBus.emit_guild_join(guild_id, player)
	return true

func leave_guild(player: Node):
	if player not in player_guilds:
		return
	
	var guild_id: String = player_guilds[player]
	var guild: Dictionary = guilds[guild_id]
	
	var player_path: String = str(player.get_path())
	var role: String = guild["member_roles"].get(player_path, "member")
	
	if role == "leader":
		if len(guild["members"]) > 1:
			var new_leader: Node = guild["members"][0]
			if new_leader == player:
				new_leader = guild["members"][1]
			guild["member_roles"][str(new_leader.get_path())] = "leader"
		else:
			delete_guild(guild_id)
			return
	
	guild["members"].erase(player)
	guild["member_roles"].erase(player_path)
	player_guilds.erase(player)
	
	EventBus.emit_guild_leave(guild_id, player)

func delete_guild(guild_id: String):
	if guild_id not in guilds:
		return
	
	var guild: Dictionary = guilds[guild_id]
	
	for member in guild["members"]:
		player_guilds.erase(member)
	
	guilds.erase(guild_id)
	
	EventBus.emit_guild_delete(guild_id)

func invite_player(inviter: Node, invitee: Node) -> bool:
	if inviter not in player_guilds:
		return false
	
	var guild_id: String = player_guilds[inviter]
	var guild: Dictionary = guilds[guild_id]
	
	var inviter_path: String = str(inviter.get_path())
	var role: String = guild["member_roles"].get(inviter_path, "member")
	
	if "invite" not in guild["roles"][role]["permissions"] and role != "leader":
		return false
	
	EventBus.emit_guild_invite(guild_id, inviter, invitee)
	return true

func kick_member(kicker: Node, member: Node) -> bool:
	if kicker not in player_guilds:
		return false
	
	var guild_id: String = player_guilds[kicker]
	var guild: Dictionary = guilds[guild_id]
	
	var kicker_path: String = str(kicker.get_path())
	var kicker_role: String = guild["member_roles"].get(kicker_path, "member")
	
	if "kick" not in guild["roles"][kicker_role]["permissions"] and kicker_role != "leader":
		return false
	
	if member not in guild["members"]:
		return false
	
	guild["members"].erase(member)
	guild["member_roles"].erase(str(member.get_path()))
	player_guilds.erase(member)
	
	EventBus.emit_guild_kick(guild_id, member)
	return true

func promote_member(promoter: Node, member: Node, new_role: String) -> bool:
	if promoter not in player_guilds:
		return false
	
	var guild_id: String = player_guilds[promoter]
	var guild: Dictionary = guilds[guild_id]
	
	var promoter_path: String = str(promoter.get_path())
	var promoter_role: String = guild["member_roles"].get(promoter_path, "member")
	
	if "manage" not in guild["roles"][promoter_role]["permissions"] and promoter_role != "leader":
		return false
	
	if new_role not in guild["roles"]:
		return false
	
	var member_path: String = str(member.get_path())
	if member_path not in guild["member_roles"]:
		return false
	
	guild["member_roles"][member_path] = new_role
	
	EventBus.emit_guild_promote(guild_id, member, new_role)
	return true

func add_guild_experience(guild_id: String, amount: int):
	if guild_id not in guilds:
		return
	
	var guild: Dictionary = guilds[guild_id]
	guild["experience"] += amount
	
	var required_exp: int = calculate_required_exp(guild["level"])
	while guild["experience"] >= required_exp:
		guild["experience"] -= required_exp
		guild["level"] += 1
		EventBus.emit_guild_level_up(guild_id, guild["level"])

func calculate_required_exp(level: int) -> int:
	return level * 1000

func get_max_members(level: int) -> int:
	return 10 + level * 5

func get_guild(player: Node) -> Dictionary:
	var guild_id: String = player_guilds.get(player, "")
	return guilds.get(guild_id, {})

func get_guild_by_id(guild_id: String) -> Dictionary:
	return guilds.get(guild_id, {})

func get_player_role(player: Node) -> String:
	var guild_id: String = player_guilds.get(player, "")
	if not guild_id:
		return ""
	
	var guild: Dictionary = guilds[guild_id]
	return guild["member_roles"].get(str(player.get_path()), "")

func has_permission(player: Node, permission: String) -> bool:
	var guild_id: String = player_guilds.get(player, "")
	if not guild_id:
		return false
	
	var guild: Dictionary = guilds[guild_id]
	var role: String = guild["member_roles"].get(str(player.get_path()), "member")
	
	return permission in guild["roles"][role]["permissions"] or role == "leader"
