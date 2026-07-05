class_name PlayerStateManager
extends Resource

var player_color: PlayerColorResource
var player_resources: Dictionary[String, float]
var built_structures: Dictionary[String, Array] = {}
var knowledge_cards: Array[KnowledgeCardResource]

var last_built_structure_type: StructureResource

const MAX_KNOWLEDGE_CARD: int = 5

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

func get_built_structures() -> Dictionary[String, Array]:
	return built_structures

func get_setup_phase_production_earning_queue() -> Array[GameResourceFormula]:
	var earning_queue: Array[GameResourceFormula] = []
	for structure_type_key in built_structures:
		var structures: Array = built_structures[structure_type_key]
		for current_structure_built_data: BuiltData in structures:
			var production_array: Array[GameResourceFormula] = current_structure_built_data.structure.setup_phase_production
			earning_queue.append_array(production_array)
	return earning_queue

func get_knowledge_cards() -> Array[KnowledgeCardResource]:
	return knowledge_cards

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

func update_game_resource(game_resource: GameResource, value: float) -> float:
	var resource_key: String = game_resource.name
	var new_value = player_resources[resource_key] + value
	player_resources[resource_key] = new_value
	return new_value

func add_knowledge_card(knowledge_card: KnowledgeCardResource):
	if knowledge_cards.size() == MAX_KNOWLEDGE_CARD:
		return
	knowledge_cards.push_back(knowledge_card)
