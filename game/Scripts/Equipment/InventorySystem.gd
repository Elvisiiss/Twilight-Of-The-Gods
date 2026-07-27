extends Node

var inventory_size: int = 50
var items: Array = []
var gold: int = 0

func _ready():
    items = []
    gold = 0

func add_item(item: Dictionary, quantity: int = 1):
    if items.size() >= inventory_size:
        return false
    
    for i in range(quantity):
        if items.size() >= inventory_size:
            return false
        items.append(item.duplicate())
    
    return true

func remove_item(item_id: String, quantity: int = 1):
    var removed = 0
    var to_remove: Array = []
    
    for i in range(items.size() - 1, -1, -1):
        if removed >= quantity:
            break
        
        if items[i].get("id", "") == item_id:
            to_remove.append(i)
            removed += 1
    
    for index in to_remove:
        items.remove(index)
    
    return removed

func get_item(index: int) -> Dictionary:
    if index < 0 or index >= items.size():
        return {}
    return items[index]

func get_items_by_type(item_type: String) -> Array:
    var result = []
    for item in items:
        if item.get("type", "") == item_type:
            result.append(item)
    return result

func has_item(item_id: String) -> bool:
    for item in items:
        if item.get("id", "") == item_id:
            return true
    return false

func get_item_count(item_id: String) -> int:
    var count = 0
    for item in items:
        if item.get("id", "") == item_id:
            count += 1
    return count

func get_empty_slots() -> int:
    return inventory_size - items.size()

func is_full() -> bool:
    return items.size() >= inventory_size

func add_gold(amount: int):
    gold += amount

func remove_gold(amount: int) -> bool:
    if gold >= amount:
        gold -= amount
        return true
    return false

func get_gold() -> int:
    return gold

func use_item(index: int) -> bool:
    if index < 0 or index >= items.size():
        return false
    
    var item = items[index]
    var item_type = item.get("type", "")
    
    match item_type:
        "consumable":
            return _use_consumable(item, index)
        "equipment":
            return _equip_item(item, index)
    
    return false

func _use_consumable(item: Dictionary, index: int) -> bool:
    var effect = item.get("effect", {})
    
    if "hp_restore" in effect:
        if get_parent().has_method("add_to_base_stat"):
            get_parent().add_to_base_stat("hp", effect["hp_restore"])
    
    if "mp_restore" in effect:
        if get_parent().has_method("add_to_base_stat"):
            get_parent().add_to_base_stat("mp", effect["mp_restore"])
    
    items.remove(index)
    return true

func _equip_item(item: Dictionary, index: int) -> bool:
    if get_parent().has_method("equip_item"):
        var success = get_parent().equip_item(item)
        if success:
            items.remove(index)
            return true
    return false

func clear_inventory():
    items.clear()
