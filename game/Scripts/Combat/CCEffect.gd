class CCEffect:
	enum CCType {
		STUN,
		FROZEN,
		PETRIFY,
		KNOCKUP,
		SLEEP,
		BANISH,
		SLOW,
		ROOT,
		BLIND,
		SILENCE,
		DISARM
	}
	
	var cc_type: CCType
	var duration: float
	var remaining_duration: float
	var strength: float
	var source: String
	var is_hard_cc: bool
	
	func _init(cc_type: CCType, duration: float, strength: float = 1.0, source: String = ""):
		self.cc_type = cc_type
		self.duration = duration
		self.remaining_duration = duration
		self.strength = strength
		self.source = source
		self.is_hard_cc = cc_type in [CCType.STUN, CCType.FROZEN, CCType.PETRIFY, CCType.KNOCKUP, CCType.SLEEP, CCType.BANISH]
	
	func tick(delta: float):
		remaining_duration -= delta
	
	func is_expired() -> bool:
		return remaining_duration <= 0
	
	func get_effect_value() -> float:
		return strength * (remaining_duration / duration)
