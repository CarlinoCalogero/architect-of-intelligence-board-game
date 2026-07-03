class_name PlayerStateManager
extends Resource

var structure_manager: StructureManager

func _init(game_definition: GameDefinition):
	structure_manager = StructureManager.new(game_definition.get_structures_definition())

func get_structure_manager() -> StructureManager:
	return structure_manager
