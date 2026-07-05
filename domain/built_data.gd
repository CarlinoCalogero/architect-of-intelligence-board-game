class_name BuiltData
extends RefCounted

var structure: StructureResource
var cell_position: Vector2i

func _init(new_structure: StructureResource, new_cell_position: Vector2i) -> void:
	structure = new_structure
	cell_position = new_cell_position
