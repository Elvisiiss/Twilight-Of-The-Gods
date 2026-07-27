class TalentData:
	enum TalentGrade {
		YELLOW,
		MYSTIC,
		EARTH,
		HEAVEN,
		SAINT,
		DIVINE,
		SUPER_DIVINE,
		ETERNAL,
		HEAVENLY_DAO
	}
	
	var id: String
	var name: String
	var description: String
	var grade: TalentGrade
	var effect_type: String
	var effect_value: float
	var effect_target: String
	var duration: float
	var cooldown: float
	var max_stars: int
	var current_stars: int
	var proficiency: int
	var is_active: bool
	var skill_effects: Array
	
	func _init():
		self.id = ""
		self.name = ""
		self.description = ""
		self.grade = TalentGrade.YELLOW
		self.effect_type = ""
		self.effect_value = 0.0
		self.effect_target = ""
		self.duration = 0.0
		self.cooldown = 0.0
		self.max_stars = 10
		self.current_stars = 1
		self.proficiency = 0
		self.is_active = false
		self.skill_effects = []
	
	static func from_dict(data: Dictionary) -> TalentData:
		var talent: TalentData = TalentData.new()
		talent.id = data.get("id", "")
		talent.name = data.get("name", "")
		talent.description = data.get("description", "")
		talent.grade = data.get("grade", TalentGrade.YELLOW)
		talent.effect_type = data.get("effect_type", "")
		talent.effect_value = data.get("effect_value", 0.0)
		talent.effect_target = data.get("effect_target", "")
		talent.duration = data.get("duration", 0.0)
		talent.cooldown = data.get("cooldown", 0.0)
		talent.max_stars = data.get("max_stars", 10)
		talent.current_stars = data.get("current_stars", 1)
		talent.proficiency = data.get("proficiency", 0)
		talent.is_active = data.get("is_active", false)
		talent.skill_effects = data.get("skill_effects", [])
		return talent
