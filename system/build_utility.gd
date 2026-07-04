class_name BuildUtility
extends Control

@export var grid_placememt_system: GridPlacementSystem

@onready var button: Button = $Button
@onready var item_list: ItemList = $ItemList

var last_built_item_index: int = -1
var current_buildable_structures: Dictionary[String, float]

func _ready():
	assert(grid_placememt_system, "No active placement system")
	
	GameManager.player_turn_started.connect(_on_player_turn_started)
	GameManager.player_turn_ended.connect(_on_player_turn_ended)
	GameManager.buidable_structure_disabled.connect(_on_buidable_structure_disabled)
	
	grid_placememt_system.structure_built.connect(_on_structure_built)
	
	_populate_item_list()
	_on_player_turn_ended()

func _populate_item_list():
	for structure: StructureResource in GameManager.get_buildable_structure_list():
		var item_index: int = item_list.add_item(structure.name, structure.texture)
		item_list.set_item_metadata(item_index, structure)
		current_buildable_structures[structure.name] = item_index

func toggle_structures_item_list():
	item_list.visible = not item_list.visible

func set_buildable_structure_subset(structure_keys: Array[String]):
	for available_structure_key in current_buildable_structures:
		if not structure_keys.has(available_structure_key):
			item_list.set_item_disabled(current_buildable_structures[available_structure_key], true)

func _reset():
	last_built_item_index = -1

func _on_button_pressed() -> void:
	toggle_structures_item_list()

func _on_item_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	last_built_item_index = index
	var structure: StructureResource = item_list.get_item_metadata(index)
	grid_placememt_system.set_building(structure.texture)
	item_list.hide()

func _on_structure_built() -> void:
	if last_built_item_index < 0 or last_built_item_index >= item_list.item_count:
		return

	var structure: StructureResource = item_list.get_item_metadata(last_built_item_index)
	
	# -- Handle structure build limit
	if GameManager.on_structure_built(structure):
		item_list.remove_item(last_built_item_index)
		current_buildable_structures.erase(structure.name)
	
	# -- Handle construction earnings
	var on_build_earnings: Dictionary[String, float] = GameManager.get_earnings_from_structure_building_completion(structure)
	for game_resource_key in on_build_earnings:
		var earned_amount: float = on_build_earnings[game_resource_key]
		GameManager.update_current_player_resource(game_resource_key, earned_amount)
	
	last_built_item_index = -1

func _on_player_turn_started():
	button.disabled = false

func _on_player_turn_ended():
	item_list.hide()
	button.disabled = true

func _on_buidable_structure_disabled(structure_keys: Array[String]):
	set_buildable_structure_subset(structure_keys)
