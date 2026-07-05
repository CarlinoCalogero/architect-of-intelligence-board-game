class_name HarvestAction
extends RefCounted

var producting_structure_built_data: BuiltData
var formula: GameResourceFormula

func _init(new_producting_structure_built_data: BuiltData, new_formula: GameResourceFormula):
	producting_structure_built_data = new_producting_structure_built_data
	formula = new_formula
