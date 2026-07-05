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
	
	var harvest_action: HarvestAction = harvest_queue.front()
	if GameManager.is_local_player_playing():
		var dice_amount: int = harvest_action.formula.number_of_dice_to_roll
		GameManager.roll_dice(dice_amount)
		pass

func _build_harvest_queue() -> void:
	harvest_queue.clear()
	
	var player_built_structures: Dictionary[String, Array] = GameManager.get_current_player_built_structure()
	for structure_type_key in player_built_structures:
		var current_type_structure_built_structures_list: Array = player_built_structures[structure_type_key]
		for buit_structure_data in current_type_structure_built_structures_list:
			var structure: StructureResource = buit_structure_data.structure
			for harvest_formula in structure.turn_production:
				harvest_queue.append(HarvestAction.new(structure, harvest_formula))

func dice_rolled(rolls: Array[int]):
	print("magica doremi, sinfony melody")
	pass
