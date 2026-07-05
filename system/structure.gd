class_name Structure
extends Node2D

@export var structure_resource: StructureResource:
	set(new_structure_resource):
		structure_resource = new_structure_resource
		# Only try to update the sprite if the node has fully entered the tree
		if is_node_ready():
			_on_structure_resource_changed()

var tile_size: Vector2
var cell_position: Vector2i
var player_owner_index: int = -1
var valid_upgrade_new_cell_position: Vector2i = Vector2i.MAX

@onready var structure_sprite_2d: Sprite2D = $StructureSprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

@onready var structure_info_tooltip_canvas_layer: CanvasLayer = $StructureInfoTooltipCanvasLayer
@onready var structure_info_tooltip_panel_container: PanelContainer = $StructureInfoTooltipCanvasLayer/StructureInfoTooltipPanelContainer

@onready var structure_label: Label = $StructureInfoTooltipCanvasLayer/StructureInfoTooltipPanelContainer/VBoxContainer/StructureLabel

@onready var production_v_box_container: VBoxContainer = $StructureInfoTooltipCanvasLayer/StructureInfoTooltipPanelContainer/VBoxContainer/ProductionVBoxContainer
@onready var production_item_list: ItemList = $StructureInfoTooltipCanvasLayer/StructureInfoTooltipPanelContainer/VBoxContainer/ProductionVBoxContainer/ProductionItemList

@onready var next_tier_v_box_container: VBoxContainer = $StructureInfoTooltipCanvasLayer/StructureInfoTooltipPanelContainer/VBoxContainer/NextTierVBoxContainer
@onready var next_tier_label: Label = $StructureInfoTooltipCanvasLayer/StructureInfoTooltipPanelContainer/VBoxContainer/NextTierVBoxContainer/HBoxContainer/NextTierLabel
@onready var next_tier_texture_rect: TextureRect = $StructureInfoTooltipCanvasLayer/StructureInfoTooltipPanelContainer/VBoxContainer/NextTierVBoxContainer/HBoxContainer/NextTierTextureRect
@onready var next_tier_item_list: ItemList = $StructureInfoTooltipCanvasLayer/StructureInfoTooltipPanelContainer/VBoxContainer/NextTierVBoxContainer/NextTierItemList

const SCALE_PERCENTAGE: float = 0.8
const TOOLTIP_MOUSE_OFFSET: Vector2 = Vector2(15, 15)
const SEARCH_TO_FIT_ON_UPDATE_RADIUS: int = 1 # Can move up to N tiles away to fit

func _ready() -> void:
	GameManager.game_resource_changed.connect(_on_game_resource_changed)
	
	_reset()

func change_color(color: Color):
	structure_sprite_2d.modulate = color

func _on_structure_resource_changed() -> void:
	var texture: Texture2D = structure_resource.texture
	structure_sprite_2d.texture = texture
	
	if texture != null:
		var target_size = texture.get_size()
		
		# ==========================================
		# DYNAMIC COLLISION SHAPE UPDATE
		# Create a brand new rectangle shape so we don't accidentally modify other buildings
		var new_shape = RectangleShape2D.new()
		new_shape.size = target_size # Make the shape the exact size of the image
		collision_shape_2d.shape = new_shape
		# ==========================================
		
		# Fallback size just in case the animation isn't set up yet
		var original_size = Vector2(32.0, 32.0)
		
		if animated_sprite_2d.sprite_frames != null:
			var current_anim = animated_sprite_2d.animation
			
			if animated_sprite_2d.sprite_frames.get_frame_count(current_anim) > 0:
				var frame_texture = animated_sprite_2d.sprite_frames.get_frame_texture(current_anim, 0)
				
				if frame_texture != null:
					original_size = frame_texture.get_size()
		
		animated_sprite_2d.scale = (target_size / original_size) * SCALE_PERCENTAGE
	
	# -- TOOLTIP CREATION LOGIC
	structure_label.text = "[" + structure_resource.name + "]"
	
	if not structure_resource.turn_production.is_empty():
		production_v_box_container.show()
		production_item_list.clear()
		var productions: Array[GameResourceFormula] = structure_resource.turn_production
		for production: GameResourceFormula in productions:
			var unit_of_measurement: String = production.resource_type.unit_of_measurement
			if not unit_of_measurement:
				unit_of_measurement = production.resource_type.name
			var production_formula: String = str(production.number_of_dice_to_roll) + " dice * "
			if production.is_single_formula_for_all_structures_of_same_type:
				production_formula += "sum of all " + str(production.single_formula_for_all_structures_of_same_type_sum_multiplier_resource_type.name) + " * "
			production_formula += str(production.multiplier_value) + " " + unit_of_measurement
			production_item_list.add_item(production_formula)
	else:
		production_v_box_container.hide()
	
	var structure_next_tier: StructureResource = structure_resource.next_tier
	if structure_resource.next_tier:
		next_tier_v_box_container.show()
		next_tier_label.text = structure_next_tier.name
		next_tier_texture_rect.texture = structure_next_tier.texture
		
		next_tier_item_list.clear()
		var upgrade_costs: Array[Transaction] = structure_resource.next_tier.building_cost
		for cost: Transaction in upgrade_costs:
			var unit_of_measurement: String = cost.resource_type.unit_of_measurement
			if not unit_of_measurement:
				unit_of_measurement = cost.resource_type.name
			var cost_text: String = str(cost.amount) + " " + unit_of_measurement
			next_tier_item_list.add_item(cost_text)
	else:
		next_tier_v_box_container.hide()
	
	_reset()
	_check_if_structure_can_be_upgraded()

func _check_if_structure_can_be_upgraded() -> bool:
	if not GameManager.is_player_local_player(player_owner_index):
		animated_sprite_2d.hide()
		return false
	
	var next_tier_structure: StructureResource = structure_resource.next_tier
	if next_tier_structure:
		# Look for valid footprint space based on new texture size
		valid_upgrade_new_cell_position = _find_valid_upgrade_position(next_tier_structure)
		if valid_upgrade_new_cell_position == Vector2i.MAX:
			animated_sprite_2d.hide()
			return false
		
		var upgrade_costs: Array[Transaction] = next_tier_structure.building_cost
		var current_player_resources: Dictionary[String, float] = GameManager.get_current_player_resources()
		
		var is_can_upgrade: bool = true
		for cost in upgrade_costs:
			var resource_name: String = cost.resource_type.name
			
			if current_player_resources[resource_name] < cost.amount:
				is_can_upgrade = false
				break # The player can't afford this, STOP checking the other costs!
		
		# print("Next Tier Upgrade Update | structure: [", structure_resource.name, "], can be upgraded: [", is_can_upgrade,"]")
		
		if is_can_upgrade:
			animated_sprite_2d.show()
		else:
			animated_sprite_2d.hide()
		
		return is_can_upgrade
	
	animated_sprite_2d.hide()
	return false

# -- FOOTPRINT AND UPGRADE LOGIC

# Dynamically calculates the cells needed, mirroring GridPlacementSystem
func _get_footprint_cells(origin_cell: Vector2i, resource: StructureResource) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if not resource or not resource.texture:
		cells.append(origin_cell)
		return cells
		
	var tex_size = resource.texture.get_size()
	var tiles_wide = max(1, int(tex_size.x / tile_size.x))
	var tiles_tall = max(1, int(tex_size.y / tile_size.y))
	
	for x in range(tiles_wide):
		for y in range(tiles_tall):
			cells.append(origin_cell + Vector2i(-x, -y))
			
	return cells

# Dynamically calculates the visual centering offset, mirroring GridPlacementSystem
func _get_visual_offset(resource: StructureResource) -> Vector2:
	if not resource or not resource.texture:
		return Vector2.ZERO
		
	var tex_size = resource.texture.get_size()
	var tiles_wide = max(1, int(tex_size.x / tile_size.x))
	var tiles_tall = max(1, int(tex_size.y / tile_size.y))
	
	var offset_x = -(tiles_wide - 1) * tile_size.x / 2.0
	var offset_y = -(tiles_tall - 1) * tile_size.y / 2.0
	return Vector2(offset_x, offset_y)

# Spirals outwards to find a spot that can fit the newly sized footprint
func _find_valid_upgrade_position(new_structure_resource: StructureResource) -> Vector2i:
	var current_cells = _get_footprint_cells(cell_position, structure_resource)
	
	var search_offsets: Array[Vector2i] = []
	for x in range(-SEARCH_TO_FIT_ON_UPDATE_RADIUS, SEARCH_TO_FIT_ON_UPDATE_RADIUS + 1):
		for y in range(-SEARCH_TO_FIT_ON_UPDATE_RADIUS, SEARCH_TO_FIT_ON_UPDATE_RADIUS + 1):
			search_offsets.append(Vector2i(x, y))
			
	# Sort offsets to check current exact spot first, then nearest neighbors
	search_offsets.sort_custom(func(a, b): return a.length_squared() < b.length_squared())
	
	for offset in search_offsets:
		var test_origin = cell_position + offset
		var new_cells_needed = _get_footprint_cells(test_origin, new_structure_resource)
		
		var can_fit: bool = true
		for required_cell in new_cells_needed:
			# Check if occupied, IGNORING our own old cells that are about to be freed
			if GameManager.is_board_cell_occupied(required_cell) and not current_cells.has(required_cell):
				can_fit = false
				break
				
		if can_fit:
			return test_origin
			
	return Vector2i.MAX # No valid space found

func _reset():
	animated_sprite_2d.hide()
	structure_info_tooltip_canvas_layer.hide()

func _on_area_2d_mouse_entered() -> void:
	# print("Mouse entered structure: ", structure_resource.name)
	var screen_mouse_pos = get_viewport().get_mouse_position()
	structure_info_tooltip_panel_container.global_position = screen_mouse_pos + TOOLTIP_MOUSE_OFFSET
	
	structure_info_tooltip_canvas_layer.show()

func _on_area_2d_mouse_exited() -> void:
	# print("Mouse left structure: ", structure_resource.name)
	structure_info_tooltip_canvas_layer.hide()

func _on_game_resource_changed(_game_resource: GameResource, _new_value: float) -> void:
	_check_if_structure_can_be_upgraded()

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Player clicked on structure: ", structure_resource.name)
			
			if not _check_if_structure_can_be_upgraded():
				return
			
			var next_tier_structure: StructureResource = structure_resource.next_tier
			
			if valid_upgrade_new_cell_position == Vector2i.MAX:
				print("Cannot upgrade: Not enough free space nearby to fit the upgraded building!")
				return
				
			# Pay upgrade cost
			var built_data: BuiltData = BuiltData.new(next_tier_structure, valid_upgrade_new_cell_position, structure_resource.bound_resource)
			
			var upgrade_costs: Array[Transaction] = next_tier_structure.building_cost
			for cost: Transaction in upgrade_costs:
				GameManager.update_current_player_resource(cost.resource_type, -cost.amount, built_data)
			
			# Free old cells on the grid
			var old_cells = _get_footprint_cells(cell_position, structure_resource)
			for cell in old_cells:
				GameManager.remove_occupied_cell_from_board(cell)
				
			# Compute Visual Move (if building was forced to shift to a neighbor tile)
			var old_visual_offset = _get_visual_offset(structure_resource)
			var new_visual_offset = _get_visual_offset(next_tier_structure)
			var cell_diff = valid_upgrade_new_cell_position - cell_position
			var pixel_shift = Vector2(cell_diff.x * tile_size.x, cell_diff.y * tile_size.y)
			
			# Move node exactly the pixel difference between old/new tile + the new visual center offset
			global_position = global_position - old_visual_offset + pixel_shift + new_visual_offset
				
			# Update position & Occupy new cells
			cell_position = valid_upgrade_new_cell_position
			var new_cells = _get_footprint_cells(cell_position, next_tier_structure)
			for cell in new_cells:
				GameManager.add_occupied_cell_to_board(cell, self)
				
			# Apply final change (this triggers the setter and updates the sprites)
			structure_resource = next_tier_structure
