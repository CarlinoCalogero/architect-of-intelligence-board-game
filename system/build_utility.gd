class_name BuildUtility
extends Control

@export var grid_placememt_system: GridPlacementSystem

@onready var button: Button = $Button
@onready var item_list: ItemList = $ItemList

@export var cannot_build_on_resources_below_required: bool = true

var last_built_item_index: int = -1
var last_built_structure: StructureResource = null
var current_buildable_structures: Dictionary[String, int]
var current_building_color: Color

func _ready():
	assert(grid_placememt_system, "No active placement system")
	
	GameManager.player_changed.connect(_on_player_changed)
	GameManager.set_build_utility_disabled_requested.connect(_on_set_build_utility_disabled_requested)
	GameManager.buidable_structure_disabled.connect(_on_buidable_structure_disabled)
	GameManager.enable_all_buildable_structures.connect(_on_enable_all_buildable_structures)
	GameManager.build_structure_requested.connect(_on_build_structure_requested)
	GameManager.set_ui_button_disabled_requested.connect(_on_set_ui_button_disabled_requested)
	GameManager.toggle_cannot_build_on_resources_below_required.connect(_on_toggle_cannot_build_on_resources_below_required)
	
	grid_placememt_system.structure_built.connect(_on_structure_built)
	
	_populate_item_list()
	_set_utility_disabled(true)

# -- UTILITY

func _find_structure_item_list_index(target_structure: StructureResource) -> int:
	for item_index in range(item_list.item_count):
		
		var structure: StructureResource = item_list.get_item_metadata(item_index)
		
		if structure.name == target_structure.name:
			return item_index
	return -1

func _populate_item_list():
	for structure: StructureResource in GameManager.get_buildable_structure_list():
		var item_index: int = item_list.add_item(structure.name, structure.texture)
		item_list.set_item_metadata(item_index, structure)
		current_buildable_structures[structure.name] = item_index

func _change_buildings_color():
	for i in range(item_list.item_count):
		item_list.set_item_icon_modulate(i, current_building_color)

func _toggle_structures_item_list(is_next_visible: bool):
	item_list.visible = is_next_visible
	_compute_buildable_structures_based_on_available_resources()

func set_buildable_structure_subset(structure_keys: Array[String]):
	for available_structure_key in current_buildable_structures:
		item_list.set_item_disabled(current_buildable_structures[available_structure_key], not structure_keys.has(available_structure_key))

func enable_all_buildable_structures():
	for item_index in range(item_list.item_count):
		item_list.set_item_disabled(item_index, false)

func _reset():
	last_built_item_index = -1
	last_built_structure = null

func _set_utility_disabled(is_disabled: bool):
	# Only close if we need to disable, if we enable do not show it
	if is_disabled:
		_toggle_structures_item_list(not is_disabled)
	button.disabled = is_disabled

func _on_button_pressed() -> void:
	_toggle_structures_item_list(not item_list.visible)

func _on_item_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	last_built_item_index = index
	var structure: StructureResource = item_list.get_item_metadata(index)
	grid_placememt_system.set_building(structure.texture)
	item_list.hide()

func _on_structure_built(cell_position: Vector2i) -> void:
	var structure: StructureResource = null
	
	# if null last structure was not built by player
	if last_built_item_index == -1:
		structure = last_built_structure
	else:
		structure = item_list.get_item_metadata(last_built_item_index)
	
	# -- Handle structure build limit
	if GameManager.on_structure_built(structure, cell_position):
		# If structure was built by local player
		if last_built_item_index > -1 and last_built_item_index < item_list.item_count:
			item_list.remove_item(last_built_item_index)
			current_buildable_structures.erase(structure.name)
			last_built_item_index = -1
	
	# -- Handle construction earnings
	var built_data: BuiltData = BuiltData.new(structure, cell_position, structure.bound_resource)
	for on_build_earning: Transaction in structure.on_build_earnings:
		GameManager.update_current_player_resource(on_build_earning.resource_type, on_build_earning.amount, built_data)
	
	# -- Handle construction cost
	if cannot_build_on_resources_below_required:
		for building_cost: Transaction in structure.building_cost:
			GameManager.update_current_player_resource(building_cost.resource_type, -building_cost.amount, built_data)

func _on_player_changed(_new_player_index: int, player_color: PlayerColorResource):
	current_building_color = player_color.color
	print("Building color: [", current_building_color, "]")
	grid_placememt_system.set_building_color(current_building_color)
	_change_buildings_color()

func _compute_buildable_structures_based_on_available_resources():
	if not cannot_build_on_resources_below_required:
		return
	
	var current_player_resources: Dictionary[String, float] = GameManager.get_current_player_resources()
	
	for item_index in range(item_list.item_count):
		var structure: StructureResource = item_list.get_item_metadata(item_index)
		var building_costs: Array[Transaction] = structure.building_cost
		
		var is_disabled: bool = false
		for cost in building_costs:
			var resource_name: String = cost.resource_type.name
			
			if current_player_resources[resource_name] < cost.amount:
				is_disabled = true
				break # The player can't afford this, STOP checking the other costs!
		
		print("Build List Update | current player resources: ", current_player_resources)
		print("Build List Update | structure: [", structure.name, "], can be built: [", is_disabled,"]")
		
		item_list.set_item_disabled(item_index, is_disabled)

func _on_buidable_structure_disabled(structure_keys: Array[String]):
	set_buildable_structure_subset(structure_keys)

func _on_enable_all_buildable_structures() -> void:
	enable_all_buildable_structures()

func _on_build_structure_requested(structure: StructureResource):
	last_built_structure = structure
	grid_placememt_system.place_random_building(structure.texture)

func _on_set_build_utility_disabled_requested(is_disabled: bool):
	_set_utility_disabled(is_disabled)

func _on_set_ui_button_disabled_requested(is_disabled: bool):
	_set_utility_disabled(is_disabled)

func _on_toggle_cannot_build_on_resources_below_required(is_player_cannot_build_when_resources_are_below_required: bool) -> void:
	cannot_build_on_resources_below_required = is_player_cannot_build_when_resources_are_below_required
