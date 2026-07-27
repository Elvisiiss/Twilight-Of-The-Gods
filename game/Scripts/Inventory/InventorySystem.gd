extends Node

var inventory_size: int = 20
var inventory: Array = []
var equipment_slots: Dictionary = {}
var gold: int = 0

func _ready():
    inventory = []
    for i in range(inventory_size):
        inventory.append(null)
    
    equipment_slots = {
        "weapon": null,
        "armor": null,
        "helmet": null,
        "boots": null,
        "accessory": null
    }

func add_item(item: Dictionary):
    var item_id = item.get("id", "")
    var stackable = item.get("stackable", false)
    var max_stack = item.get("max_stack", 99)
    
    if stackable:
        for slot in inventory:
            if slot and slot["id"] == item_id and slot.get("count", 1) < max_stack:
                slot["count"] = slot.get("count", 1) + 1
                return true
    else:
        for i in range(inventory_size):
            if not inventory[i]:
                inventory[i] = item.duplicate()
                inventory[i]["count"] = 1
                return true
    
    return false

func remove_item(item_id: String, count: int = 1):
    for i in range(inventory_size):
        if inventory[i] and inventory[i]["id"] == item_id:
            var current_count = inventory[i].get("count", 1)
            if current_count <= count:
                inventory[i] = null
                count -= current_count
            else:
                inventory[i]["count"] = current_count - count
                count = 0
            
            if count <= 0:
                return true
    
    return false

func equip_item(item: Dictionary):
    var slot = item.get("slot", "")
    if not slot in equipment_slots:
        return false
    
    var old_item = equipment_slots[slot]
    if old_item:
        add_item(old_item)
    
    equipment_slots[slot] = item
    remove_item(item["id"], 1)
    
    return true

func unequip_item(slot: String):
    var item = equipment_slots.get(slot)
    if item:
        add_item(item)
        equipment_slots[slot] = null
        return true
    return false

func get_item_at_index(index: int) -> Dictionary:
    if index >= 0 and index < inventory_size:
        return inventory[index]
    return {}

func get_equipped_item(slot: String) -> Dictionary:
    return equipment_slots.get(slot, {})

func get_all_items() -> Array:
    return inventory

func get_equipment_stats() -> Dictionary:
    var stats = {}
    
    for slot in equipment_slots:
        var item = equipment_slots[slot]
        if item:
            var item_stats = item.get("stats", {})
            for stat_name in item_stats:
                stats[stat_name] = stats.get(stat_name, 0) + item_stats[stat_name]
    
    return stats

func get_empty_slots() -> int:
    var count = 0
    for item in inventory:
        if not item:
            count += 1
    return count

func has_item(item_id: String, count: int = 1) -> bool:
    var total = 0
    for item in inventory:
        if item and item["id"] == item_id:
            total += item.get("count", 1)
            if total >= count:
                return true
    return false

func add_gold(amount: int):
    gold += amount

func remove_gold(amount: int) -> bool:
    if gold >= amount:
        gold -= amount
        return true
    return false

func get_gold() -> int:
    return gold