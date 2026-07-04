class_name PlayerStateManager
extends Resource

class BuiltData:
	var structure: StructureResource
	var cell_position: Vector2i
	
	func _init(new_structure: StructureResource, new_cell_position: Vector2i) -> void:
		structure = new_structure
		cell_position = new_cell_position

var player_color: PlayerColorResource
var player_resources: Dictionary[String, float]
var built_structures: Dictionary[String, Array] = {}

var last_built_structure_type: StructureResource

func _init(new_player_color: PlayerColorResource, game_resources_list: Array[GameResource]):
	player_color = new_player_color
	
	for game_resource in game_resources_list:
		player_resources[game_resource.name] = 0.0

# -- GETTERS

func get_color() -> PlayerColorResource:
	return player_color

func get_game_resources() -> Dictionary[String, float]:
	return player_resources

func get_last_built_structure_type() -> StructureResource:
	return last_built_structure_type

# -- UTILITY FUNCTIONS

# If return is true player has built the maximum number of this type structure
func add_built_structure(structure: StructureResource, cell: Vector2i) -> bool:
	last_built_structure_type = structure
	
	var new_building_data = BuiltData.new(structure, cell)
	
	if built_structures.has(structure.name):
		built_structures[structure.name].append(new_building_data)
	else:
		built_structures[structure.name] = [new_building_data]
	
	if structure.building_limit_amount > 0:
		if built_structures[structure.name].size() >= structure.building_limit_amount:
			return true
	
	return false

func update_game_resource(game_resource_key: String, value: float) -> float:
	var new_value = player_resources[game_resource_key] + value
	player_resources[game_resource_key] = new_value
	return new_value
