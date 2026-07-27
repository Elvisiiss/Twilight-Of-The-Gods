class MonsterData:
	enum MonsterType {
		NORMAL,
		ELITE,
		BOSS,
		MINI_BOSS
	}
	
	var id: String
	var name: String
	var description: String
	var monster_type: MonsterType
	var level: int
	var base_stats: Dictionary
	var skills: Array
	var loot_table: Dictionary
	var exp_reward: int
	var gold_reward: int
	var aggro_range: float
	var chase_range: float
	var patrol_radius: float
	var is_respawnable: bool
	var respawn_time: float
	var is_boss: bool
	var boss_mechanics: Array
	var icon_path: String
	
	func _init():
		self.id = ""
		self.name = ""
		self.description = ""
		self.monster_type = MonsterType.NORMAL
		self.level = 1
		self.base_stats = {}
		self.skills = []
		self.loot_table = {}
		self.exp_reward = 100
		self.gold_reward = 10
		self.aggro_range = 150.0
		self.chase_range = 300.0
		self.patrol_radius = 50.0
		self.is_respawnable = true
		self.respawn_time = 30.0
		self.is_boss = false
		self.boss_mechanics = []
		self.icon_path = ""
	
	static func from_dict(data: Dictionary) -> MonsterData:
		var monster: MonsterData = MonsterData.new()
		monster.id = data.get("id", "")
		monster.name = data.get("name", "")
		monster.description = data.get("description", "")
		monster.monster_type = data.get("monster_type", MonsterType.NORMAL)
		monster.level = data.get("level", 1)
		monster.base_stats = data.get("base_stats", {})
		monster.skills = data.get("skills", [])
		monster.loot_table = data.get("loot_table", {})
		monster.exp_reward = data.get("exp_reward", 100)
		monster.gold_reward = data.get("gold_reward", 10)
		monster.aggro_range = data.get("aggro_range", 150.0)
		monster.chase_range = data.get("chase_range", 300.0)
		monster.patrol_radius = data.get("patrol_radius", 50.0)
		monster.is_respawnable = data.get("is_respawnable", true)
		monster.respawn_time = data.get("respawn_time", 30.0)
		monster.is_boss = data.get("is_boss", false)
		monster.boss_mechanics = data.get("boss_mechanics", [])
		monster.icon_path = data.get("icon_path", "")
		return monster
