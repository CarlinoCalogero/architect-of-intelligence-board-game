class_name PlayerStateManager
extends Resource

var player_color: PlayerColorResource
var player_resources: Dictionary[String, float]
var built_structures: Dictionary[String, Array] = {} # Dictionary[String, Array[BuiltData]]
var knowledge_cards: Array[KnowledgeCardResource]

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

func get_game_resources_from_key(resource_key: String) -> float:
	if not player_resources.has(resource_key):
		return 0.0
	return player_resources[resource_key]

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

func get_structure_at_cell_index(structure_type: String, cell_position: Vector2i) -> int:
	if not built_structures.has(structure_type):
		return -1
	
	var structures: Array = built_structures[structure_type]
	for index in range(structures.size()):
		var structure_built_data: BuiltData = structures[index]
		if structure_built_data.cell_position == cell_position:
			return index
	return -1

# -- UTILITY FUNCTIONS

# If return is true player has built the maximum number of this type structure
func add_built_structure(structure: StructureResource, cell: Vector2i) -> bool:
	last_built_structure_type = structure
	
	var new_building_data = BuiltData.new(structure, cell)
	if structure.bound_resource:
		new_building_data.bounded_resource = structure.bound_resource
	
	if built_structures.has(structure.name):
		built_structures[structure.name].append(new_building_data)
	else:
		built_structures[structure.name] = [new_building_data]
	
	if structure.building_limit_amount > 0:
		if built_structures[structure.name].size() >= structure.building_limit_amount:
			return true
	
	return false

# producing_structure and producing_structure_cell_position are populated only if game resource to be
# updated is due to structure production/effect
func update_game_resource(game_resource: GameResource, value: float, producing_structure_built_data: BuiltData = null) -> float:
	var resource_key: String = game_resource.name
	# print("Game Resource Update | resource_key: [", resource_key, "], current_value: [", player_resources[resource_key],"], amount: [", value,"]")
	var new_value = player_resources[resource_key] + value
	player_resources[resource_key] = new_value
	
	if producing_structure_built_data:
		var producing_structure: StructureResource = producing_structure_built_data.structure
		if producing_structure.bound_resource and producing_structure.bound_resource.name == game_resource.name:
			var producing_structure_type: String = producing_structure.name
			var producing_structure_index: int = get_structure_at_cell_index(producing_structure_type, producing_structure_built_data.cell_position)
			if producing_structure_index != -1:
				built_structures[producing_structure_type][producing_structure_index].bounded_resource_amount += value
	
	return new_value

func add_knowledge_card(knowledge_card: KnowledgeCardResource):
	knowledge_cards.push_back(knowledge_card)
