class_name TurnManager
extends Node

enum TurnPhase {
	IDLE,
	HARVEST_RESOURCES
}

var current_turn_phase: TurnPhase = TurnPhase.IDLE

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
	var player_built_structures: Dictionary[String, Array] = GameManager.get_current_player_built_structure()
	for structure_type_key in player_built_structures:
		var current_type_structure_built_structures_list: Array[BuiltData] = player_built_structures[structure_type_key]
		for structure in current_type_structure_built_structures_list:
			pass
