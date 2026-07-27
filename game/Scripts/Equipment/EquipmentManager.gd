extends Node

var equipment_slots: Dictionary = {}
var set_bonuses: Dictionary = {}
var character_stats: CharacterStats = null

func _ready():
	initialize_slots()

func initialize_slots():
	var slots: Array = [
		{"slot": "weapon", "slot_type": EquipmentData.SlotType.WEAPON},
		{"slot": "shoes", "slot_type": EquipmentData.SlotType.SHOES},
		{"slot": "heart_mirror", "slot_type": EquipmentData.SlotType.HEART_MIRROR},
		{"slot": "armor", "slot_type": EquipmentData.SlotType.ARMOR},
		{"slot": "helmet", "slot_type": EquipmentData.SlotType.HELMET},
		{"slot": "cloak", "slot_type": EquipmentData.SlotType.CLOAK},
		{"slot": "ring_left", "slot_type": EquipmentData.SlotType.RING},
		{"slot": "ring_right", "slot_type": EquipmentData.SlotType.RING},
		{"slot": "necklace", "slot_type": EquipmentData.SlotType.NECKLACE},
		{"slot": "shoulder_left", "slot_type": EquipmentData.SlotType.SHOULDER},
		{"slot": "shoulder_right", "slot_type": EquipmentData.SlotType.SHOULDER},
		{"slot": "leggings_left", "slot_type": EquipmentData.SlotType.LEGGINGS},
		{"slot": "leggings_right", "slot_type": EquipmentData.SlotType.LEGGINGS}
	]
	
	for slot_info in slots:
		equipment_slots[slot_info["slot"]] = {
			"slot_type": slot_info["slot_type"],
			"equipment": null
		}

func set_character_stats(stats: CharacterStats):
	character_stats = stats

func equip_item(slot: String, equipment: EquipmentData) -> bool:
	if slot not in equipment_slots:
		return false
	
	if equipment.level_requirement > get_owner_level():
		return false
	
	if equipment.class_requirements and not check_class_requirement(equipment.class_requirements):
		return false
	
	var slot_type: int = equipment_slots[slot]["slot_type"]
	if equipment.slot_type != slot_type:
		return false
	
	var old_equipment: EquipmentData = equipment_slots[slot]["equipment"]
	if old_equipment:
		remove_equipment_bonus(old_equipment)
	
	equipment_slots[slot]["equipment"] = equipment
	add_equipment_bonus(equipment)
	update_set_bonuses()
	
	EventBus.emit_equipment_change(get_parent(), slot, equipment)
	return true

func unequip_item(slot: String):
	if slot not in equipment_slots:
		return null
	
	var equipment: EquipmentData = equipment_slots[slot]["equipment"]
	if equipment:
		remove_equipment_bonus(equipment)
		equipment_slots[slot]["equipment"] = null
		update_set_bonuses()
		EventBus.emit_equipment_change(get_parent(), slot, null)
		return equipment
	return null

func add_equipment_bonus(equipment: EquipmentData):
	if not character_stats:
		return
	
	var rarity_multiplier: float = RaritySystem.get_rarity_multiplier(equipment.rarity)
	
	for stat_name in equipment.base_stats:
		var value: float = equipment.base_stats[stat_name] * rarity_multiplier
		character_stats.add_to_base_stat(stat_name, value)

func remove_equipment_bonus(equipment: EquipmentData):
	if not character_stats:
		return
	
	var rarity_multiplier: float = RaritySystem.get_rarity_multiplier(equipment.rarity)
	
	for stat_name in equipment.base_stats:
		var value: float = equipment.base_stats[stat_name] * rarity_multiplier
		character_stats.add_to_base_stat(stat_name, -value)

func update_set_bonuses():
	var set_counts: Dictionary = {}
	
	for slot in equipment_slots:
		var equipment: EquipmentData = equipment_slots[slot]["equipment"]
		if equipment and equipment.set_name:
			if equipment.set_name not in set_counts:
				set_counts[equipment.set_name] = 0
			set_counts[equipment.set_name] += 1
	
	for set_name in set_bonuses:
		remove_set_bonus(set_name)
	
	for set_name in set_counts:
		var count: int = set_counts[set_name]
		if count >= 2:
			apply_set_bonus(set_name, count)

func apply_set_bonus(set_name: String, count: int):
	var bonuses: Dictionary = get_set_bonuses(set_name)
	
	for bonus_count in bonuses:
		if count >= bonus_count:
			for stat_name in bonuses[bonus_count]:
				var value: float = bonuses[bonus_count][stat_name]
				character_stats.add_to_base_stat(stat_name, value)
	
	set_bonuses[set_name] = bonuses

func remove_set_bonus(set_name: String):
	if set_name not in set_bonuses:
		return
	
	var bonuses: Dictionary = set_bonuses[set_name]
	for bonus_count in bonuses:
		for stat_name in bonuses[bonus_count]:
			var value: float = bonuses[bonus_count][stat_name]
			character_stats.add_to_base_stat(stat_name, -value)
	
	set_bonuses.erase(set_name)

func get_set_bonuses(set_name: String) -> Dictionary:
	var sets: Dictionary = {
		"black_iron_set": {
			2: {"attack": 50},
			4: {"attack": 100, "crit_rate": 0.1},
			6: {"attack": 200, "crit_rate": 0.2, "special_skill": "iron_fury"}
		}
	}
	return sets.get(set_name, {})

func reduce_all_durability(percentage: float):
	for slot in equipment_slots:
		var equipment: EquipmentData = equipment_slots[slot]["equipment"]
		if equipment:
			var loss: int = int(equipment.max_durability * percentage * (1 / equipment.wear_resistance))
			equipment.durability = max(0, equipment.durability - loss)

func repair_all():
	var total_cost: int = 0
	for slot in equipment_slots:
		var equipment: EquipmentData = equipment_slots[slot]["equipment"]
		if equipment and equipment.durability < equipment.max_durability:
			var cost: int = calculate_repair_cost(equipment)
			total_cost += cost
			equipment.durability = equipment.max_durability
	return total_cost

func calculate_repair_cost(equipment: EquipmentData) -> int:
	var rarity_multiplier: float = RaritySystem.get_rarity_multiplier(equipment.rarity)
	var damage_percentage: float = 1 - equipment.durability / equipment.max_durability
	return int(rarity_multiplier * 100 * damage_percentage)

func drop_random_items(count: int) -> Array:
	var drop_list: Array = []
	var equipped_slots: Array = []
	
	for slot in equipment_slots:
		var equipment: EquipmentData = equipment_slots[slot]["equipment"]
		if equipment and not equipment.is_unique:
			equipped_slots.append({"slot": slot, "equipment": equipment})
	
	for i in range(min(count, len(equipped_slots))):
		var random_index: int = rand_range(0, len(equipped_slots))
		var slot_data: Dictionary = equipped_slots[random_index]
		drop_list.append(slot_data["equipment"])
		unequip_item(slot_data["slot"])
		equipped_slots.remove(random_index)
	
	return drop_list

func get_owner_level() -> int:
	if get_parent().has_node("LevelSystem"):
		return get_parent().get_node("LevelSystem").current_level
	return 1

func check_class_requirement(classes: Array) -> bool:
	if get_parent().has_node("ClassSystem"):
		var current_class: String = get_parent().get_node("ClassSystem").current_class
		return current_class in classes
	return true

func get_equipped_item(slot: String) -> EquipmentData:
	return equipment_slots.get(slot, {}).get("equipment", null)

func get_all_equipped_items() -> Array:
	var items: Array = []
	for slot in equipment_slots:
		var equipment: EquipmentData = equipment_slots[slot]["equipment"]
		if equipment:
			items.append(equipment)
	return items
