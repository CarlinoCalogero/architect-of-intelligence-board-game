class_name GameDefinition
extends Node

@onready var structures_definition: StructureDefinition = $StructuresDefinition

func get_structures_definition() -> StructureDefinition:
	return structures_definition
