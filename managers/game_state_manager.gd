class_name GameStateManager
extends Node

const STRUCTURES_DEFINITION_RESOURCE: Resource = preload("uid://tt2j83gkervu")

var players: Array = []
var current_player_index: int = -1

var structure_definition: StructureDefinition

func _ready():
	structure_definition = STRUCTURES_DEFINITION_RESOURCE.instantiate()
	add_child(structure_definition)
	
	var player: PlayerStateManager = PlayerStateManager.new(structure_definition)
	players.append(player)
	current_player_index = 0

func get_current_player_structure_manager() -> StructureManager:
	return players[current_player_index].get_structure_manager()
