class_name GridPlacementSystem
extends Node2D

signal structure_built(cell_position: Vector2i)

@onready var ground_tile_map_layer: TileMapLayer = $GroundTileMapLayer
@onready var built_structures: Node2D = $BuiltStructures

@onready var placement_preview: Node2D = $PlacementPreview
@onready var placement_preview_color_rect: ColorRect = $PlacementPreview/ColorRect
@onready var placement_preview_sprite_2d: Sprite2D = $PlacementPreview/Sprite2D

@export_group("Grid Visuals")
@export var draw_grid_lines: bool = true
@export var grid_color: Color = Color(1, 1, 1, 0.2)
@export var grid_line_thickness: float = 1.0

const STRUCTURE_RESOURCE: Resource = preload("res://system/structure.tscn")

var is_enabled: bool = false
var player_owner_index: int = -1
var building_texture: Texture2D
var building_color: Color
var footprint: Array[Vector2i] = []
var visual_offset: Vector2 = Vector2.ZERO

var current_grid_pos: Vector2i
var current_building_structure: StructureResource

func _ready() -> void:
	_reset()
	get_viewport().size_changed.connect(queue_redraw)

func _process(_delta: float) -> void:
	if not is_enabled:
		return
	
	_compute_placement_preview()
	
	# Tell Godot to run the _draw() function this frame so the highlights follow the mouse
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not is_enabled:
		return
	
	if event.is_action_pressed("place_structure"):
		_place_building()

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

# -- SETTER

func set_building_color(color: Color) -> void:
	building_color = color

# -- UTILITY

func get_random_valid_build_location() -> Vector2i:
	var all_board_tiles: Array[Vector2i] = ground_tile_map_layer.get_used_cells()
	var valid_placement_spots: Array[Vector2i] = []
	
	# Loop through all of them to see if the current building fits
	for tile in all_board_tiles:
		# We use your existing footprint check! 
		# This guarantees no part of the building overlaps another structure.
		if _is_footprint_clear(tile):
			valid_placement_spots.append(tile)
			
	# Safety check: What if the board is completely full?
	if valid_placement_spots.is_empty():
		push_warning("The board is full! No valid placement spots found.")
		return Vector2i.ZERO # Return a fallback (you might want to handle this in GameManager)
		
	# Pick a random valid spot from our approved list
	return valid_placement_spots.pick_random()

func setup_building_placement(building: StructureResource, player_index: int):
	current_building_structure = building
	_setup_building_texture(building.texture)
	player_owner_index = player_index

func place_random_building(building: StructureResource, player_index: int):
	setup_building_placement(building, player_index)
	
	current_grid_pos = get_random_valid_build_location()
	_place_building()

func set_building(building: StructureResource, player_index: int) -> void:
	setup_building_placement(building, player_index)
	
	placement_preview_sprite_2d.texture = building_texture
	placement_preview_sprite_2d.modulate = Color(building_color.r, building_color.g, building_color.b, 0.6)
	
	_enable()

func _place_building() -> void:
	if not _is_footprint_clear(current_grid_pos):
		return

	var structure_node: Structure = STRUCTURE_RESOURCE.instantiate()
	structure_node.global_position = ground_tile_map_layer.map_to_local(current_grid_pos) + visual_offset
	built_structures.add_child(structure_node)
	structure_node.tile_size = ground_tile_map_layer.tile_set.tile_size
	structure_node.structure_resource = current_building_structure
	structure_node.cell_position = current_grid_pos
	structure_node.player_owner_index = player_owner_index
	structure_node.change_color(building_color)

	for offset in footprint:
		var claim_pos = current_grid_pos + offset
		GameManager.add_occupied_cell_to_board(claim_pos, structure_node)
	
	_reset()
	emit_signal("structure_built", current_grid_pos)

func _setup_building_texture(new_texture: Texture2D) -> void:
	building_texture = new_texture
	
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

func _is_footprint_clear(base_pos: Vector2i) -> bool:
	for offset in footprint:
		var check_pos = base_pos + offset
		if GameManager.is_board_cell_occupied(check_pos):
			return false
	return true

func _compute_placement_preview():
	var mouse_pos = get_global_mouse_position()
	current_grid_pos = ground_tile_map_layer.local_to_map(mouse_pos)

	placement_preview.global_position = ground_tile_map_layer.map_to_local(current_grid_pos) + visual_offset
	
	if footprint.size() > 0:
		placement_preview_color_rect.show()
		
		# Set the color (Green for clear, Red for blocked)
		var is_clear = _is_footprint_clear(current_grid_pos)
		placement_preview_color_rect.color = Color(0, 1, 0, 0.4) if is_clear else Color(1, 0, 0, 0.4)
		
		# Find the extremes of your footprint to create a bounding box
		var min_x = 0
		var min_y = 0
		for offset in footprint:
			if offset.x < min_x: min_x = offset.x
			if offset.y < min_y: min_y = offset.y
			
		# Calculate the top-left pixel position
		var top_left_cell_pos = current_grid_pos + Vector2i(min_x, min_y)
		var tile_size = ground_tile_map_layer.tile_set.tile_size
		
		var top_left_cell_center = ground_tile_map_layer.map_to_local(top_left_cell_pos)
		var top_left_pixel = top_left_cell_center - (Vector2(tile_size) / 2.0)
		
		# Set the Global Position of the ColorRect
		placement_preview_color_rect.global_position = ground_tile_map_layer.to_global(top_left_pixel)
		
		# Calculate total size based on how many tiles the footprint spans
		var tiles_wide = abs(min_x) + 1
		var tiles_tall = abs(min_y) + 1
		placement_preview_color_rect.size = Vector2(tiles_wide * tile_size.x, tiles_tall * tile_size.y)
		
	else:
		placement_preview_color_rect.hide()

func _enable():
	is_enabled = true
	placement_preview.show()

func _reset():
	footprint.clear()
	placement_preview.hide()
	queue_redraw()
	is_enabled = false
