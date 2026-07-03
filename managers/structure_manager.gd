class_name StructureManager
extends Resource

var structures_definition: StructureDefinition
var built_structures_tracker: Dictionary = {}

func _init(new_structures_definition: StructureDefinition) -> void:
	structures_definition = new_structures_definition

# If return is true player has built the maximum number of this type structure
func on_structure_built(structure: StructureResource) -> bool:
	if structure.is_building_limited:
		if not built_structures_tracker.has(structure.name):
			built_structures_tracker[structure.name] = 0
			
		built_structures_tracker[structure.name] += 1
		
		if built_structures_tracker[structure.name] >= structure.limit_amount:
			return true
	return false

func get_buildable_structure_list() -> Array[StructureResource]:
	return structures_definition.buildable_structures
