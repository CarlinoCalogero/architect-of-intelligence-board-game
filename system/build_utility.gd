class_name BuildUtility
extends Control

@export var grid_placememt_system: GridPlacementSystem

@onready var button: Button = $Button
@onready var item_list: ItemList = $ItemList

var last_built_item_index: int = -1
var current_buildable_structures: Dictionary[String, int]
var current_building_color: Color

func _ready():
	assert(grid_placememt_system, "No active placement system")
	
	GameManager.player_changed.connect(_on_player_changed)
	GameManager.set_build_utility_disabled_requested.connect(_on_set_build_utility_disabled_requested)
	GameManager.buidable_structure_disabled.connect(_on_buidable_structure_disabled)
	GameManager.build_structure_requested.connect(_on_build_structure_requested)
	GameManager.set_ui_button_disabled_requested.connect(_on_set_ui_button_disabled_requested)
	
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

func set_buildable_structure_subset(structure_keys: Array[String]):
	for available_structure_key in current_buildable_structures:
		item_list.set_item_disabled(current_buildable_structures[available_structure_key], not structure_keys.has(available_structure_key))

func _reset():
	last_built_item_index = -1

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
	if last_built_item_index < 0 or last_built_item_index >= item_list.item_count:
		return

	var structure: StructureResource = item_list.get_item_metadata(last_built_item_index)
	
	# -- Handle structure build limit
	if GameManager.on_structure_built(structure, cell_position):
		item_list.remove_item(last_built_item_index)
		current_buildable_structures.erase(structure.name)
	
	# -- Handle construction earnings
	for on_build_earning: Transaction in structure.on_build_earnings:
		GameManager.update_current_player_resource(on_build_earning.resource_type, on_build_earning.amount)
	
	last_built_item_index = -1

func _on_player_changed(_new_player_index: int, player_color: PlayerColorResource):
	current_building_color = player_color.color
	print("Building color: [", current_building_color, "]")
	grid_placememt_system.set_building_color(current_building_color)
	_change_buildings_color()

func _on_buidable_structure_disabled(structure_keys: Array[String]):
	set_buildable_structure_subset(structure_keys)

func _on_build_structure_requested(structure_type: StructureResource):
	var structure_type_index: int = _find_structure_item_list_index(structure_type)
	if structure_type_index == -1:
		return
	last_built_item_index = structure_type_index
	grid_placememt_system.place_random_building(structure_type.texture)

func _on_set_build_utility_disabled_requested(is_disabled: bool):
	_set_utility_disabled(is_disabled)

func _on_set_ui_button_disabled_requested(is_disabled: bool):
	_set_utility_disabled(is_disabled)
