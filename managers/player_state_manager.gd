class_name PlayerStateManager
extends Resource

var player_color: PlayerColorResource
var player_resources: Dictionary[String, float]
var built_structures_type_tracker: Dictionary = {}
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
func check_if_player_has_built_all_structures_of_type(structure: StructureResource) -> bool:
	last_built_structure_type = structure
	
	if structure.building_limit_amount > 0:
		if not built_structures_type_tracker.has(structure.name):
			built_structures_type_tracker[structure.name] = 0
		
		built_structures_type_tracker[structure.name] += 1
		
		if built_structures_type_tracker[structure.name] >= structure.building_limit_amount:
			return true
	
	return false

func update_game_resource(game_resource_key: String, value: float) -> float:
	var new_value = player_resources[game_resource_key] + value
	player_resources[game_resource_key] = new_value
	return new_value
