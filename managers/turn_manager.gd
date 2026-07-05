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
	pass
