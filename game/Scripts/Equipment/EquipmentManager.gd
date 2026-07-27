extends Node

var equipment_slots: Dictionary = {}
var equipment_bonus: Dictionary = {}
var character_stats: CharacterStats = null

func _ready():
    equipment_slots = {
        "weapon": null,
        "armor": null,
        "helmet": null,
        "boots": null,
        "accessory1": null,
        "accessory2": null,
        "ring1": null,
        "ring2": null,
        "amulet": null,
        "cloak": null,
        "gloves": null,
        "belt": null,
        "artifact": null
    }
    equipment_bonus = {}

func set_character_stats(stats: CharacterStats):
    character_stats = stats

func equip_item(equipment: Dictionary):
    var slot = equipment.get("slot", "")
    if slot == "" or not slot in equipment_slots:
        return false
    
    if equipment_slots[slot]:
        unequip_item(slot)
    
    equipment_slots[slot] = equipment
    
    if character_stats:
        character_stats.set_equipment_bonus(_calculate_total_bonus())
    
    var game_manager = get_parent()
    if game_manager and game_manager.has_method("get_event_bus"):
        game_manager.get_event_bus().emit_equipment_change(get_parent(), slot, equipment)
    
    return true

func unequip_item(slot: String):
    if not slot in equipment_slots or not equipment_slots[slot]:
        return false
    
    equipment_slots[slot] = null
    
    if character_stats:
        character_stats.set_equipment_bonus(_calculate_total_bonus())
    
    var game_manager = get_parent()
    if game_manager and game_manager.has_method("get_event_bus"):
        game_manager.get_event_bus().emit_equipment_change(get_parent(), slot, null)
    
    return true

func get_equipped_item(slot: String) -> Dictionary:
    return equipment_slots.get(slot, null)

func get_all_equipped_items() -> Dictionary:
    return equipment_slots.duplicate()

func _calculate_total_bonus() -> Dictionary:
    var bonus = {}
    
    for slot in equipment_slots:
        var equipment = equipment_slots[slot]
        if equipment:
            var stats = equipment.get("stats", {})
            for stat_name in stats:
                if stat_name in bonus:
                    bonus[stat_name] += stats[stat_name]
                else:
                    bonus[stat_name] = stats[stat_name]
    
    return bonus

func can_equip(equipment: Dictionary, character_level: int, character_class: String) -> bool:
    var level_req = equipment.get("level_requirement", 1)
    if character_level < level_req:
        return false
    
    var class_req = equipment.get("class_requirement", "")
    if class_req != "" and class_req != character_class:
        return false
    
    return true

func get_equipment_stats() -> Dictionary:
    return equipment_bonus
