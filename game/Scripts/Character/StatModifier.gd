class StatModifier:
	enum ModifierType {
		ADDITIVE,
		MULTIPLICATIVE,
		PERCENTAGE
	}
	
	var stat_name: String
	var value: float
	var modifier_type: ModifierType
	var source: String
	var duration: float
	var is_permanent: bool
	
	func _init(stat_name: String, value: float, modifier_type: ModifierType, source: String, duration: float = 0, is_permanent: bool = false):
		self.stat_name = stat_name
		self.value = value
		self.modifier_type = modifier_type
		self.source = source
		self.duration = duration
		self.is_permanent = is_permanent
