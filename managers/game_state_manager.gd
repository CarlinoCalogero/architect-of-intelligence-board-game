class_name GameStateManager
extends Node

signal current_game_resource_changed(game_resource_key: String, new_value: float)

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

func get_player_last_built_structure_type(player_index: int) -> StructureResource:
	return players[player_index].get_last_built_structure_type()

func update_player_resource(player_index: int, game_resource_key: String, value: float) -> void:
	var new_value: float = players[player_index].update_game_resource(game_resource_key, value)
	emit_signal("current_game_resource_changed", game_resource_key, new_value)

func check_if_player_has_built_all_structures_of_type(player_index: int, structure: StructureResource) -> bool:
	return  players[player_index].check_if_player_has_built_all_structures_of_type(structure)
