class_name GridPlacementSystem
extends Node2D

@onready var ground_tile_map_layer: TileMapLayer = $GroundTileMapLayer
@onready var placement_preview_sprite_2d: Sprite2D = $PlacementPreviewSprite2D

@export var building_texture: Texture2D

@export_group("Grid Visuals")
@export var draw_grid_lines: bool = true
@export var grid_color: Color = Color(1, 1, 1, 0.2)
@export var grid_line_thickness: float = 1.0

const STRUCTURE_RESOURCE: Resource = preload("res://system/structure.tscn")

var footprint: Array[Vector2i] = []
var visual_offset: Vector2 = Vector2.ZERO

var current_grid_pos: Vector2i
var occupied_cells: Dictionary = {}

func _ready() -> void:
	if building_texture:
		set_building(building_texture)
		
	get_viewport().size_changed.connect(queue_redraw)

func set_building(new_texture: Texture2D) -> void:
	building_texture = new_texture
	placement_preview_sprite_2d.texture = building_texture
	
	placement_preview_sprite_2d.modulate = Color(1, 1, 1, 0.6)
	
	var tile_size = ground_tile_map_layer.tile_set.tile_size
	var tex_size = building_texture.get_size()
	
	var tiles_wide = max(1, int(tex_size.x / tile_size.x))
	var tiles_tall = max(1, int(tex_size.y / tile_size.y))
	
	footprint.clear()
	for x in range(tiles_wide):
		for y in range(tiles_tall):
			footprint.append(Vector2i(-x, -y))
			
	var offset_x = -(tiles_wide - 1) * tile_size.x / 2.0
	var offset_y = -(tiles_tall - 1) * tile_size.y / 2.0
	visual_offset = Vector2(offset_x, offset_y)

func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	current_grid_pos = ground_tile_map_layer.local_to_map(mouse_pos)

	placement_preview_sprite_2d.global_position = ground_tile_map_layer.map_to_local(current_grid_pos) + visual_offset

	# Tell Godot to run the _draw() function this frame so the highlights follow the mouse
	queue_redraw()

func _is_footprint_clear(base_pos: Vector2i) -> bool:
	for offset in footprint:
		var check_pos = base_pos + offset
		if occupied_cells.has(check_pos):
			return false 
	return true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("place_structure"):
		_place_building()

func _place_building() -> void:
	if not _is_footprint_clear(current_grid_pos):
		return

	var structure_node = STRUCTURE_RESOURCE.instantiate()
	structure_node.global_position = ground_tile_map_layer.map_to_local(current_grid_pos) + visual_offset
	add_child(structure_node)
	structure_node.texture = building_texture

	for offset in footprint:
		var claim_pos = current_grid_pos + offset
		occupied_cells[claim_pos] = structure_node

func _draw() -> void:
	if ground_tile_map_layer.tile_set == null:
		return
		
	var tile_size = ground_tile_map_layer.tile_set.tile_size
	
	if draw_grid_lines:
		var screen_size = get_viewport_rect().size
		var tiles_wide = ceil(screen_size.x / tile_size.x)
		var tiles_tall = ceil(screen_size.y / tile_size.y)
		
		var total_width = tiles_wide * tile_size.x
		var total_height = tiles_tall * tile_size.y
		
		for x in range(tiles_wide + 1):
			var start_point = Vector2(x * tile_size.x, 0)
			var end_point = Vector2(x * tile_size.x, total_height)
			draw_line(start_point, end_point, grid_color, grid_line_thickness)
			
		for y in range(tiles_tall + 1):
			var start_point = Vector2(0, y * tile_size.y)
			var end_point = Vector2(total_width, y * tile_size.y)
			draw_line(start_point, end_point, grid_color, grid_line_thickness)

	if footprint.size() > 0:
		var is_clear = _is_footprint_clear(current_grid_pos)
		var highlight_color = Color(0, 1, 0, 0.4) if is_clear else Color(1, 0, 0, 0.4)
		
		for offset in footprint:
			var cell_pos = current_grid_pos + offset
			var cell_center = ground_tile_map_layer.map_to_local(cell_pos)
			
			# map_to_local finds the exact center. We must subtract half the tile size 
			# to find the top-left corner so draw_rect() aligns perfectly inside the grid lines.
			var top_left = cell_center - (Vector2(tile_size) / 2.0)
			var rect = Rect2(top_left, tile_size)
			
			# "true" at the end tells Godot to fill the rectangle solidly with color
			draw_rect(rect, highlight_color, true)
