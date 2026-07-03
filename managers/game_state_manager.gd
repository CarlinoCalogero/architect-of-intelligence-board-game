class_name GameStateManager
extends Node

const GAME_DEFINITION_RESOURCE: Resource = preload("uid://dso50mfa3p71h")

var players: Array = []
var current_player_index: int = -1

var game_definition: GameDefinition

func _ready():
	game_definition = GAME_DEFINITION_RESOURCE.instantiate()
	add_child(game_definition)
	
	var player: PlayerStateManager = PlayerStateManager.new(game_definition)
	players.append(player)
	current_player_index = 0

func get_current_player_structure_manager() -> StructureManager:
	return players[current_player_index].get_structure_manager()
