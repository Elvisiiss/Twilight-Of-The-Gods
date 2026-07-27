class SkillEffect:
	enum EffectType {
		DAMAGE,
		HEAL,
		BUFF,
		DEBUFF,
		CROWD_CONTROL,
		SHIELD,
		TELEPORT,
		SUMMON,
		LIFESTEAL,
		REFLECT,
		INVINCIBLE,
		DOT,
		HOT
	}
	
	var effect_type: EffectType
	var value: float
	var duration: float
	var target_type: String
	var stat_name: String
	var chance: float
	var stack_count: int
	var max_stacks: int
	var tick_interval: float
	var metadata: Dictionary
	
	func _init():
		self.effect_type = EffectType.DAMAGE
		self.value = 0.0
		self.duration = 0.0
		self.target_type = "enemy"
		self.stat_name = ""
		self.chance = 1.0
		self.stack_count = 1
		self.max_stacks = 1
		self.tick_interval = 0.0
		self.metadata = {}
	
	static func create(effect_type: EffectType, value: float) -> SkillEffect:
		var effect: SkillEffect = SkillEffect.new()
		effect.effect_type = effect_type
		effect.value = value
		return effect
	
	static func from_dict(data: Dictionary) -> SkillEffect:
		var effect: SkillEffect = SkillEffect.new()
		effect.effect_type = data.get("effect_type", EffectType.DAMAGE)
		effect.value = data.get("value", 0.0)
		effect.duration = data.get("duration", 0.0)
		effect.target_type = data.get("target_type", "enemy")
		effect.stat_name = data.get("stat_name", "")
		effect.chance = data.get("chance", 1.0)
		effect.stack_count = data.get("stack_count", 1)
		effect.max_stacks = data.get("max_stacks", 1)
		effect.tick_interval = data.get("tick_interval", 0.0)
		effect.metadata = data.get("metadata", {})
		return effect
