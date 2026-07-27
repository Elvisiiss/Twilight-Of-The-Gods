extends Node

signal on_damage(attacker: Node, target: Node, damage: float, damage_type: String)
signal on_kill(killer: Node, victim: Node)
signal on_level_up(character: Node, new_level: int)
signal on_item_pickup(character: Node, item: Dictionary)
signal on_skill_cast(caster: Node, skill_id: String, target: Node)
signal on_quest_complete(character: Node, quest_id: String)
signal on_death(character: Node, killer: Node)
signal on_revive(character: Node)
signal on_area_enter(character: Node, area_id: String)
signal on_npc_interact(character: Node, npc_id: String)
signal on_equipment_change(character: Node, slot: String, equipment: Dictionary)
signal on_stat_change(character: Node, stat_name: String, old_value: float, new_value: float)
signal on_combat_start(attacker: Node, target: Node)
signal on_combat_end(winner: Node, loser: Node)
signal on_buff_added(character: Node, buff_id: String)
signal on_buff_removed(character: Node, buff_id: String)

func emit_damage(attacker: Node, target: Node, damage: float, damage_type: String):
	on_damage.emit(attacker, target, damage, damage_type)

func emit_kill(killer: Node, victim: Node):
	on_kill.emit(killer, victim)

func emit_level_up(character: Node, new_level: int):
	on_level_up.emit(character, new_level)

func emit_item_pickup(character: Node, item: Dictionary):
	on_item_pickup.emit(character, item)

func emit_skill_cast(caster: Node, skill_id: String, target: Node):
	on_skill_cast.emit(caster, skill_id, target)

func emit_quest_complete(character: Node, quest_id: String):
	on_quest_complete.emit(character, quest_id)

func emit_death(character: Node, killer: Node):
	on_death.emit(character, killer)

func emit_revive(character: Node):
	on_revive.emit(character)

func emit_area_enter(character: Node, area_id: String):
	on_area_enter.emit(character, area_id)

func emit_npc_interact(character: Node, npc_id: String):
	on_npc_interact.emit(character, npc_id)

func emit_equipment_change(character: Node, slot: String, equipment: Dictionary):
	on_equipment_change.emit(character, slot, equipment)

func emit_stat_change(character: Node, stat_name: String, old_value: float, new_value: float):
	on_stat_change.emit(character, stat_name, old_value, new_value)

func emit_combat_start(attacker: Node, target: Node):
	on_combat_start.emit(attacker, target)

func emit_combat_end(winner: Node, loser: Node):
	on_combat_end.emit(winner, loser)

func emit_buff_added(character: Node, buff_id: String):
	on_buff_added.emit(character, buff_id)

func emit_buff_removed(character: Node, buff_id: String):
	on_buff_removed.emit(character, buff_id)
