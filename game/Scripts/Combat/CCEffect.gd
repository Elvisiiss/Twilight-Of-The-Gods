extends Node

enum CCType { STUN, SLOW, FREEZE, FEAR, SILENCE, ROOT }

var cc_type: CCType = CCType.STUN
var duration: float = 0.0
var source: Node = null
var is_active: bool = true

func _ready():
    pass

func _init(p_cc_type: CCType, p_duration: float, p_source: Node = null):
    cc_type = p_cc_type
    duration = p_duration
    source = p_source
    is_active = true

func get_cc_type() -> CCType:
    return cc_type

func get_duration() -> float:
    return duration

func get_source() -> Node:
    return source

func is_expired() -> bool:
    return duration <= 0

func update(delta: float):
    if is_active:
        duration -= delta
        if duration <= 0:
            is_active = false
