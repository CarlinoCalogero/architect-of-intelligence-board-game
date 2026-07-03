class_name PlayerStateManager
extends Resource

var structure_manager: StructureManager

func _init(structure_definition: StructureDefinition):
	structure_manager = StructureManager.new(structure_definition)

func get_structure_manager() -> StructureManager:
	return structure_manager
