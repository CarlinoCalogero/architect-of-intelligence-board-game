class_name PlayerStateManager
extends Resource

var structure_manager: StructureManager
var game_resource_manager: GameResourceManager

func _init(game_definition: GameDefinition):
	structure_manager = StructureManager.new(game_definition.get_structures_definition())
	game_resource_manager = GameResourceManager.new(game_definition.get_game_resources())

func get_structure_manager() -> StructureManager:
	return structure_manager
