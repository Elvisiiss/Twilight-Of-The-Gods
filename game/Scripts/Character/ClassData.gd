class ClassData:
	var id: String
	var name: String
	var description: String
	var stat_multipliers: Dictionary
	var attribute_bonus: Dictionary
	var primary_attributes: Array
	var secondary_attributes: Array
	var skills: Array
	var tier: int
	var is_hidden: bool
	var unlock_condition: String
	
	func _init():
		self.id = ""
		self.name = ""
		self.description = ""
		self.stat_multipliers = {}
		self.attribute_bonus = {}
		self.primary_attributes = []
		self.secondary_attributes = []
		self.skills = []
		self.tier = 1
		self.is_hidden = false
		self.unlock_condition = ""
	
	static func from_dict(data: Dictionary) -> ClassData:
		var cls: ClassData = ClassData.new()
		cls.id = data.get("id", "")
		cls.name = data.get("name", "")
		cls.description = data.get("description", "")
		cls.stat_multipliers = data.get("stat_multipliers", {})
		cls.attribute_bonus = data.get("attribute_bonus", {})
		cls.primary_attributes = data.get("primary_attributes", [])
		cls.secondary_attributes = data.get("secondary_attributes", [])
		cls.skills = data.get("skills", [])
		cls.tier = data.get("tier", 1)
		cls.is_hidden = data.get("is_hidden", false)
		cls.unlock_condition = data.get("unlock_condition", "")
		return cls
