class_name BuildUtility
extends Control

@export var grid_placememt_system: GridPlacementSystem
@export var buildable_structures: Array[StructureResource]

@onready var item_list: ItemList = $ItemList

var last_built_item_index: int = -1
var built_structures_tracker: Dictionary = {}

func _ready():
	assert(grid_placememt_system, "No active placement system")
	grid_placememt_system.structure_built.connect(_on_structure_built)
	item_list.hide()
	_populate_item_list()

func _populate_item_list():
	for structure in buildable_structures:
		var item_index: int = item_list.add_item(structure.name, structure.texture)
		item_list.set_item_metadata(item_index, structure)

func toggle_structures_item_list():
	item_list.visible = not item_list.visible

func _reset():
	last_built_item_index = -1

func _on_button_pressed() -> void:
	toggle_structures_item_list()

func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	last_built_item_index = index
	var structure: StructureResource = item_list.get_item_metadata(index)
	grid_placememt_system.set_building(structure.texture)
	item_list.hide()

func _on_structure_built() -> void:
	if last_built_item_index < 0 or last_built_item_index >= item_list.item_count:
		return

	var structure: StructureResource = item_list.get_item_metadata(last_built_item_index)
	
	if structure.is_building_limited:
		if not built_structures_tracker.has(structure.name):
			built_structures_tracker[structure.name] = 0
			
		built_structures_tracker[structure.name] += 1
		
		if built_structures_tracker[structure.name] >= structure.limit_amount:
			item_list.remove_item(last_built_item_index)
			
	last_built_item_index = -1
