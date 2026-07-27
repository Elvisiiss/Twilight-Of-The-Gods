extends Node

enum ItemType {
	EQUIPMENT,
	CONSUMABLE,
	MATERIAL,
	QUEST,
	CURRENCY
}

var inventory_size: int = 50
var items: Array = []
var equipment_manager: EquipmentManager = null

func _ready():
	pass

func set_equipment_manager(manager: EquipmentManager):
	equipment_manager = manager

func add_item(item: Dictionary, count: int = 1) -> bool:
	if get_total_items() >= inventory_size:
		return false
	
	var existing_slot: Dictionary = find_item(item["id"])
	if existing_slot and item.get("stackable", false):
		existing_slot["count"] += count
	else:
		items.append({
			"id": item["id"],
			"name": item["name"],
			"type": item.get("type", ItemType.MATERIAL),
			"data": item,
			"count": count,
			"stackable": item.get("stackable", false)
		})
	
	EventBus.emit_inventory_change()
	return true

func remove_item(item_id: String, count: int = 1) -> bool:
	var slot: Dictionary = find_item(item_id)
	if not slot:
		return false
	
	if slot["count"] <= count:
		items.erase(slot)
	else:
		slot["count"] -= count
	
	EventBus.emit_inventory_change()
	return true

func find_item(item_id: String) -> Dictionary:
	for slot in items:
		if slot["id"] == item_id:
			return slot
	return null

func use_item(item_id: String, target: Node = null) -> bool:
	var slot: Dictionary = find_item(item_id)
	if not slot:
		return false
	
	var item: Dictionary = slot["data"]
	
	match item.get("type", ItemType.MATERIAL):
		ItemType.CONSUMABLE:
			use_consumable(item, target)
		ItemType.EQUIPMENT:
			if equipment_manager:
				equip_item_from_inventory(item_id)
	
	remove_item(item_id, 1)
	return true

func use_consumable(item: Dictionary, target: Node = null):
	if not target:
		target = get_parent()
	
	if target.has_node("CharacterStats"):
		var stats: CharacterStats = target.get_node("CharacterStats")
		
		if "hp" in item.get("effects", {}):
			var hp_amount: float = item["effects"]["hp"]
			var current_hp: float = stats.get_stat("hp")
			var max_hp: float = stats.get_stat("hp")
			stats.set_base_stat("hp", min(max_hp, current_hp + hp_amount))
		
		if "mp" in item.get("effects", {}):
			var mp_amount: float = item["effects"]["mp"]
			var current_mp: float = stats.get_stat("mp")
			var max_mp: float = stats.get_stat("mp")
			stats.set_base_stat("mp", min(max_mp, current_mp + mp_amount))
		
		if "buff" in item.get("effects", {}):
			var buff_data: Dictionary = item["effects"]["buff"]
			var modifier: StatModifier = StatModifier.new(
				buff_data["stat"],
				buff_data["value"],
				StatModifier.ModifierType.ADDITIVE,
				"consumable",
				buff_data.get("duration", 0)
			)
			stats.add_modifier(modifier)

func equip_item_from_inventory(item_id: String):
	var slot: Dictionary = find_item(item_id)
	if not slot:
		return
	
	var equipment: EquipmentData = EquipmentData.from_dict(slot["data"])
	var target_slot: String = get_equipment_slot(equipment.slot_type)
	
	if target_slot:
		var old_equipment: EquipmentData = equipment_manager.unequip_item(target_slot)
		if old_equipment:
			add_item(old_equipment.to_dict())
		
		equipment_manager.equip_item(target_slot, equipment)
		remove_item(item_id)

func get_equipment_slot(slot_type: int) -> String:
	var slot_map: Dictionary = {
		EquipmentData.SlotType.WEAPON: "weapon",
		EquipmentData.SlotType.SHOES: "shoes",
		EquipmentData.SlotType.HEART_MIRROR: "heart_mirror",
		EquipmentData.SlotType.ARMOR: "armor",
		EquipmentData.SlotType.HELMET: "helmet",
		EquipmentData.SlotType.CLOAK: "cloak",
		EquipmentData.SlotType.RING: "ring_left",
		EquipmentData.SlotType.NECKLACE: "necklace",
		EquipmentData.SlotType.SHOULDER: "shoulder_left",
		EquipmentData.SlotType.LEGGINGS: "leggings_left"
	}
	return slot_map.get(slot_type, "")

func get_total_items() -> int:
	var count: int = 0
	for slot in items:
		count += slot["count"]
	return count

func get_free_slots() -> int:
	return inventory_size - len(items)

func get_items_by_type(item_type: ItemType) -> Array:
	return items.filter(func(item): return item["type"] == item_type)

func has_item(item_id: String, count: int = 1) -> bool:
	var slot: Dictionary = find_item(item_id)
	return slot and slot["count"] >= count
