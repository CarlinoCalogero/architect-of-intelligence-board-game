class_name HarvestAction
extends RefCounted

var structure: StructureResource
var formula: GameResourceFormula

func _init(p_struct: StructureResource, p_form: GameResourceFormula):
	structure = p_struct
	formula = p_form
