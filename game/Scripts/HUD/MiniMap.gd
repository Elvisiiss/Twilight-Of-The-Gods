extends HUDElement

var map_texture: TextureRect = null
var player_icon: TextureRect = null
var map_manager: MapManager = null

func _ready():
	super._ready()
	map_texture = $MapTexture
	player_icon = $PlayerIcon
	
	var map_manager_node: Node = get_node_or_null("/root/MapManager")
	if map_manager_node:
		map_manager = map_manager_node

func update_hud():
	if not player or not map_manager:
		return
	
	var current_map: Dictionary = map_manager.get_current_map()
	var map_name: String = current_map.get("name", "")
	
	var background_path: String = current_map.get("background", "")
	if background_path:
		var background: Texture = load(background_path)
		if background:
			map_texture.texture = background
	
	var player_pos: Vector2 = player.global_position
	var map_width: float = current_map.get("width", 2000)
	var map_height: float = current_map.get("height", 1500)
	
	var icon_x: float = (player_pos.x / map_width) * map_texture.rect_size.x
	var icon_y: float = (player_pos.y / map_height) * map_texture.rect_size.y
	
	player_icon.rect_position = Vector2(icon_x - 5, icon_y - 5)

func _draw():
	if not player or not map_manager:
		return
	
	var current_map: Dictionary = map_manager.get_current_map()
	
	var areas: Array = current_map.get("areas", [])
	for area_id in areas:
		var area: Dictionary = map_manager.get_area_info(area_id)
		if area:
			var bounds: Rect2 = area["bounds"]
			
			var x: float = (bounds.position.x / current_map.get("width", 2000)) * map_texture.rect_size.x
			var y: float = (bounds.position.y / current_map.get("height", 1500)) * map_texture.rect_size.y
			var w: float = (bounds.size.x / current_map.get("width", 2000)) * map_texture.rect_size.x
			var h: float = (bounds.size.y / current_map.get("height", 1500)) * map_texture.rect_size.y
			
			draw_rect(Rect2(x, y, w, h), Color(0, 1, 0, 0.3))
			draw_string(get_font("font"), Vector2(x, y), area.get("name", ""), Color(1, 1, 1))
