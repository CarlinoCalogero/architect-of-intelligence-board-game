class_name BuiltData
extends RefCounted

var structure: StructureResource
var cell_position: Vector2i
var bounded_resource: GameResource = null
var bounded_resource_amount: float = 0

func _init(new_structure: StructureResource, new_cell_position: Vector2i, new_bounded_resource: GameResource = null, new_bounded_resource_amount: float = 0) -> void:
	structure = new_structure
	cell_position = new_cell_position
	bounded_resource = new_bounded_resource
	bounded_resource_amount = new_bounded_resource_amount
