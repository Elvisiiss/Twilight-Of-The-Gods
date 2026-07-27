class DamageData:
	enum DamageType {
		PHYSICAL,
		MAGICAL,
		TRUE,
		PERCENTAGE_HP,
		SOUL,
		UNDEAD
	}
	
	var attacker: Node
	var target: Node
	var damage: float
	var damage_type: DamageType
	var is_crit: bool
	var crit_multiplier: float
	var armor_penetration: float
	var magic_penetration: float
	var lifesteal: float
	var thorns_return: float
	var source_id: String
	var skill_effects: Array
	
	func _init():
		self.attacker = null
		self.target = null
		self.damage = 0.0
		self.damage_type = DamageType.PHYSICAL
		self.is_crit = false
		self.crit_multiplier = 2.0
		self.armor_penetration = 0.0
		self.magic_penetration = 0.0
		self.lifesteal = 0.0
		self.thorns_return = 0.0
		self.source_id = ""
		self.skill_effects = []
	
	static func create(attacker: Node, target: Node, damage: float, damage_type: DamageType) -> DamageData:
		var data: DamageData = DamageData.new()
		data.attacker = attacker
		data.target = target
		data.damage = damage
		data.damage_type = damage_type
		return data
