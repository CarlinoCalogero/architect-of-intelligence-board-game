class_name GameStateManager
extends Node

signal current_game_resource_changed(game_resource: GameResource, new_value: float)

var players: Array = []

func setup(player_colors: Array[PlayerColorResource], game_resources_list: Array[GameResource]) -> void:
	for player_color_index in range(player_colors.size()):
		var player: PlayerStateManager = PlayerStateManager.new(player_colors[player_color_index], game_resources_list)
		players.append(player)

# -- GAME STATE FUNCTIONS

func get_number_of_players() -> int:
	return players.size()

# -- PLAYER FUNCTIONS

func get_player_color(player_index: int) -> PlayerColorResource:
	return players[player_index].get_color()

func get_player_resources(player_index: int) -> Dictionary[String, float]:
	return players[player_index].get_game_resources()

func get_player_resources_from_key(player_index: int, resource_key: String) -> float:
	return players[player_index].get_game_resources_from_key(resource_key)

func get_player_last_built_structure_type(player_index: int) -> StructureResource:
	return players[player_index].get_last_built_structure_type()

func get_player_built_structures(player_index: int) -> Dictionary[String, Array]:
	return players[player_index].get_built_structures()

func get_player_setup_phase_production_earning_queue(player_index: int) -> Array[GameResourceFormula]:
	return players[player_index].get_setup_phase_production_earning_queue()

func update_player_resource(player_index: int, game_resource: GameResource, value: float, producing_structure_built_data: BuiltData = null) -> float:
	var new_value: float = players[player_index].update_game_resource(game_resource, value, producing_structure_built_data)
	emit_signal("current_game_resource_changed", game_resource, new_value)
	return new_value

func add_built_structure(player_index: int, structure: StructureResource, cell: Vector2i) -> bool:
	return  players[player_index].add_built_structure(structure, cell)

func get_player_knowledge_cards(player_index: int) -> Array[KnowledgeCardResource]:
	return players[player_index].get_knowledge_cards()

func add_player_knowledge_card(player_index: int, knowledge_card: KnowledgeCardResource):
	return players[player_index].add_knowledge_card(knowledge_card)
