extends Control

var inventory_grid: GridContainer = null
var inventory_system: InventorySystem = null
var is_visible: bool = false

func _ready():
	inventory_grid = $InventoryGrid
	connect_to_player()

func connect_to_player():
	var players: Array = get_tree().get_nodes_in_group("players")
	if not players.empty():
		var player: Node = players[0]
		if player.has_node("InventorySystem"):
			inventory_system = player.get_node("InventorySystem")
			EventBus.connect("inventory_change", self, "_on_inventory_change")

func show_panel():
	is_visible = true
	visible = true
	update_inventory()

func hide_panel():
	is_visible = false
	visible = false

func toggle_panel():
	if is_visible:
		hide_panel()
	else:
		show_panel()

func update_inventory():
	if not inventory_system:
		return
	
	clear_grid()
	
	var items: Array = inventory_system.items
	
	for item in items:
		var slot: TextureRect = TextureRect.new()
		slot.expand = true
		
		var icon: Texture = load("res://Assets/Icons/" + item["id"] + ".png")
		if icon:
			slot.texture = icon
		else:
			slot.texture = load("res://Assets/Icons/default.png")
		
		if item["count"] > 1:
			var label: Label = Label.new()
			label.text = str(item["count"])
			label.add_style_override("font_color", Color(1, 1, 1))
			label.rect_position = Vector2(20, 20)
			slot.add_child(label)
		
		slot.connect("input_event", self, "_on_slot_click", [item])
		
		inventory_grid.add_child(slot)

func clear_grid():
	for child in inventory_grid.get_children():
		child.queue_free()

func _on_inventory_change():
	if is_visible:
		update_inventory()

func _on_slot_click(slot: TextureRect, event: InputEvent, item: Dictionary):
	if event is InputEventMouseButton and event.pressed:
		inventory_system.use_item(item["id"])
