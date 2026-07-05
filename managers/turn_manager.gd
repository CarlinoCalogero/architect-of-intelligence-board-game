class_name TurnManager
extends Node

enum TurnPhase {
	IDLE,
	HARVEST_RESOURCES
}

var current_turn_phase: TurnPhase = TurnPhase.IDLE
var harvest_queue: Array[HarvestAction] = []

func start_game_session():
	_change_phase(TurnPhase.HARVEST_RESOURCES)

func _change_phase(new_phase: TurnPhase) -> void:
	current_turn_phase = new_phase
	
	match current_turn_phase:
		TurnPhase.HARVEST_RESOURCES:
			_harvest_resources_phase()
			return

func _harvest_resources_phase():
	print("Harvesting resources...")
	_build_harvest_queue()
	_do_harvest_resource()

func _do_harvest_resource():
	var harvest_action: HarvestAction = harvest_queue.front()
	var dice_amount: int = harvest_action.formula.number_of_dice_to_roll
	GameManager.roll_dice(dice_amount)

func _build_harvest_queue() -> void:
	harvest_queue.clear()
	
	var player_built_structures: Dictionary[String, Array] = GameManager.get_current_player_built_structure()
	for structure_type_key in player_built_structures:
		var current_type_structure_built_structures_list: Array = player_built_structures[structure_type_key]
		
		for buit_structure_data_index in range(current_type_structure_built_structures_list.size()):
			var buit_structure_data: BuiltData = current_type_structure_built_structures_list[buit_structure_data_index]
			var structure: StructureResource = buit_structure_data.structure
			for harvest_formula in structure.turn_production:
				var harvest_action: HarvestAction = HarvestAction.new(structure, harvest_formula)
				# if harvest is not due to single structure but by the "sum" of the structures
				# we only add the harvest action at the end
				if harvest_formula.is_single_formula_for_all_structures_of_same_type:
					if buit_structure_data_index == current_type_structure_built_structures_list.size() - 1:
						harvest_queue.append(harvest_action)
				else:
					harvest_queue.append(harvest_action)

func dice_rolled(rolls: Array[int]):
	if TurnPhase.HARVEST_RESOURCES:
		var harvest_action: HarvestAction = harvest_queue.pop_front()
		var harvest_formula: GameResourceFormula = harvest_action.formula
		var dice_sum: int = rolls.reduce(func(accum, number): return accum + number, 0)
		var new_value: float = dice_sum
		# if harvest is not due to single structure but by the "sum" of the structures
		# we multiply here the resource
		if harvest_formula.is_single_formula_for_all_structures_of_same_type:
			var resource_type_key: String = harvest_formula.single_formula_for_all_structures_of_same_type_sum_multiplier_resource_type.name
			new_value *= GameManager.get_current_player_resource_from_key(resource_type_key)
		new_value *=  harvest_formula.multiplier_value
		GameManager.update_current_player_resource(harvest_formula.resource_type, new_value)
		
		if not harvest_queue.is_empty():
			_do_harvest_resource()
		return
