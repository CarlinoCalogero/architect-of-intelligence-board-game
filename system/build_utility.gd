class_name BuildUtility
extends Control

@export var grid_placememt_system: GridPlacementSystem
@export var game_state_manager: GameStateManager

@onready var item_list: ItemList = $ItemList

var last_built_item_index: int = -1

func _ready():
	assert(grid_placememt_system, "No active placement system")
	grid_placememt_system.structure_built.connect(_on_structure_built)
	item_list.hide()
	_populate_item_list()

func _populate_item_list():
	for structure in game_state_manager.get_current_player_structure_manager().get_buildable_structure_list():
		var item_index: int = item_list.add_item(structure.name, structure.texture)
		item_list.set_item_metadata(item_index, structure)

func toggle_structures_item_list():
	item_list.visible = not item_list.visible

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
	
	if game_state_manager.get_current_player_structure_manager().on_structure_built(structure):
		item_list.remove_item(last_built_item_index)
			
	last_built_item_index = -1
