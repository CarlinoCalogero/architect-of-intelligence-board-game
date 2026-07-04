class_name StructureManager
extends Resource

var structures: Array[StructureResource]
var built_structures_tracker: Dictionary = {}

func _init(new_structures: Array[StructureResource]) -> void:
	structures = new_structures

func get_buildable_structure_list() -> Array[StructureResource]:
	return structures

# If return is true player has built the maximum number of this type structure
func on_structure_built(structure: StructureResource) -> bool:
	if structure.building_limit_amount > 0:
		if not built_structures_tracker.has(structure.name):
			built_structures_tracker[structure.name] = 0
			
		built_structures_tracker[structure.name] += 1
		
		if built_structures_tracker[structure.name] >= structure.building_limit_amount:
			return true
	return false
