class_name GameStateManager
extends Node

signal current_game_resource_changed(game_resource_key: String, new_value: float)

const GAME_DEFINITION_RESOURCE: Resource = preload("uid://dso50mfa3p71h")

var players: Array = []
var current_player_index: int = -1

var game_definition: GameDefinition

func _ready():
	game_definition = GAME_DEFINITION_RESOURCE.instantiate()
	add_child(game_definition)

func setup(number_of_players: int) -> void:
	for i in range(number_of_players):
		var player: PlayerStateManager = PlayerStateManager.new(game_definition)
		players.append(player)
		current_player_index = 0

func get_current_player_structure_manager() -> StructureManager:
	return players[current_player_index].get_structure_manager()

func get_current_player_game_resource_manager() -> GameResourceManager:
	return players[current_player_index].get_game_resource_manager()

func get_current_player_resources() -> Dictionary[String, float]:
	return players[current_player_index].get_game_resource_manager().get_current_resources()

func update_current_player_resource(game_resource_key: String, value: float) -> void:
	var new_value: float = players[current_player_index].get_game_resource_manager().update_current_resource(game_resource_key, value)
	emit_signal("current_game_resource_changed", game_resource_key, new_value)
