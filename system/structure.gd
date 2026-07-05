class_name Structure
extends Node2D

@export var structure_resource: StructureResource:
	set(new_structure_resource):
		structure_resource = new_structure_resource
		# Only try to update the sprite if the node has fully entered the tree
		if is_node_ready():
			_on_structure_resource_changed()

var cell_position: Vector2i
var player_owner_index: int = -1

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
			print("building cost: [", cost_text, "]")
			next_tier_item_list.add_item(cost_text)
	else:
		next_tier_v_box_container.hide()
	
	_reset()

func _check_if_structure_can_be_upgraded() -> bool:
	if not GameManager.is_player_local_player(player_owner_index):
		animated_sprite_2d.hide()
		return false
	
	if structure_resource.next_tier:
		var upgrade_costs: Array[Transaction] = structure_resource.next_tier.building_cost
		var current_player_resources: Dictionary[String, float] = GameManager.get_current_player_resources()
		
		var is_can_upgrade: bool = true
		for cost in upgrade_costs:
			var resource_name: String = cost.resource_type.name
			
			if current_player_resources[resource_name] < cost.amount:
				is_can_upgrade = false
				break # The player can't afford this, STOP checking the other costs!
		
		print("Next Tier Upgrade Update | structure: [", structure_resource.name, "], can be upgraded: [", is_can_upgrade,"]")
		
		if is_can_upgrade:
			animated_sprite_2d.show()
		else:
			animated_sprite_2d.hide()
		
		return is_can_upgrade
	
	animated_sprite_2d.hide()
	return false

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
			var built_data: BuiltData = BuiltData.new(structure_resource, cell_position, structure_resource.bound_resource)
			var next_tier_structure: StructureResource = structure_resource.next_tier
			var upgrade_costs: Array[Transaction] = next_tier_structure.building_cost
			for cost: Transaction in upgrade_costs:
				GameManager.update_current_player_resource(cost.resource_type, -cost.amount, built_data)
			structure_resource = next_tier_structure
