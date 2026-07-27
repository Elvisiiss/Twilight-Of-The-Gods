class SkillData:
	enum SkillType {
		ACTIVE,
		PASSIVE,
		ULTIMATE
	}
	
	enum DamageType {
		PHYSICAL,
		MAGICAL,
		TRUE
	}
	
	var id: String
	var name: String
	var description: String
	var skill_type: SkillType
	var damage_type: DamageType
	var mana_cost: float
	var cooldown: float
	var range: float
	var cast_time: float
	var damage: float
	var damage_scaling: Dictionary
	var effects: Array
	var target_type: String
	var cast_type: String
	var animation_name: String
	var icon_path: String
	var level: int
	var max_level: int
	var proficiency: int
	var required_level: int
	
	func _init():
		self.id = ""
		self.name = ""
		self.description = ""
		self.skill_type = SkillType.ACTIVE
		self.damage_type = DamageType.PHYSICAL
		self.mana_cost = 10.0
		self.cooldown = 5.0
		self.range = 100.0
		self.cast_time = 0.0
		self.damage = 50.0
		self.damage_scaling = {}
		self.effects = []
		self.target_type = "single"
		self.cast_type = "instant"
		self.animation_name = ""
		self.icon_path = ""
		self.level = 1
		self.max_level = 5
		self.proficiency = 0
		self.required_level = 1
	
	static func from_dict(data: Dictionary) -> SkillData:
		var skill: SkillData = SkillData.new()
		skill.id = data.get("id", "")
		skill.name = data.get("name", "")
		skill.description = data.get("description", "")
		skill.skill_type = data.get("skill_type", SkillType.ACTIVE)
		skill.damage_type = data.get("damage_type", DamageType.PHYSICAL)
		skill.mana_cost = data.get("mana_cost", 10.0)
		skill.cooldown = data.get("cooldown", 5.0)
		skill.range = data.get("range", 100.0)
		skill.cast_time = data.get("cast_time", 0.0)
		skill.damage = data.get("damage", 50.0)
		skill.damage_scaling = data.get("damage_scaling", {})
		skill.effects = data.get("effects", [])
		skill.target_type = data.get("target_type", "single")
		skill.cast_type = data.get("cast_type", "instant")
		skill.animation_name = data.get("animation_name", "")
		skill.icon_path = data.get("icon_path", "")
		skill.level = data.get("level", 1)
		skill.max_level = data.get("max_level", 5)
		skill.proficiency = data.get("proficiency", 0)
		skill.required_level = data.get("required_level", 1)
		return skill
