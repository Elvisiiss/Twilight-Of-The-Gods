class EquipmentData:
	enum SlotType {
		WEAPON,
		SHOES,
		HEART_MIRROR,
		ARMOR,
		HELMET,
		CLOAK,
		RING,
		NECKLACE,
		SHOULDER,
		LEGGINGS
	}
	
	var id: String
	var name: String
	var description: String
	var slot_type: SlotType
	var rarity: int
	var level_requirement: int
	var class_requirements: Array
	var base_stats: Dictionary
	var special_effects: Array
	var durability: int
	var max_durability: int
	var wear_resistance: float
	var set_name: String
	var set_bonus: Dictionary
	var is_unique: bool
	var icon_path: String
	
	func _init():
		self.id = ""
		self.name = ""
		self.description = ""
		self.slot_type = SlotType.WEAPON
		self.rarity = 0
		self.level_requirement = 1
		self.class_requirements = []
		self.base_stats = {}
		self.special_effects = []
		self.durability = 100
		self.max_durability = 100
		self.wear_resistance = 1.0
		self.set_name = ""
		self.set_bonus = {}
		self.is_unique = false
		self.icon_path = ""
	
	static func from_dict(data: Dictionary) -> EquipmentData:
		var eq: EquipmentData = EquipmentData.new()
		eq.id = data.get("id", "")
		eq.name = data.get("name", "")
		eq.description = data.get("description", "")
		eq.slot_type = data.get("slot_type", 0)
		eq.rarity = data.get("rarity", 0)
		eq.level_requirement = data.get("level_requirement", 1)
		eq.class_requirements = data.get("class_requirements", [])
		eq.base_stats = data.get("base_stats", {})
		eq.special_effects = data.get("special_effects", [])
		eq.durability = data.get("durability", 100)
		eq.max_durability = data.get("max_durability", 100)
		eq.wear_resistance = data.get("wear_resistance", 1.0)
		eq.set_name = data.get("set_name", "")
		eq.set_bonus = data.get("set_bonus", {})
		eq.is_unique = data.get("is_unique", false)
		eq.icon_path = data.get("icon_path", "")
		return eq
