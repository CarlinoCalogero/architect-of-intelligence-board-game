extends Node

signal player_turn_started
signal player_turn_ended
signal buidable_structure_disabled(structure_keys: Array[String])
signal game_resource_changed(game_resource_key: String, new_value: float)

@onready var cpu_player_wait_timer: Timer = $CPUPlayerWaitTimer

enum GamePhase {
	MAIN_MENU,
	SETUP_TURN,
	PLAYER_TURN
}

const GAME_STATE_MANAGER = preload("uid://bh1pyslmu1ara")
const CITY_STRUCTURE_RESOURCE: StructureResource = preload("uid://l2bs1modugmn")

var current_state: GamePhase = GamePhase.MAIN_MENU

var game_state_manager: GameStateManager

func _ready() -> void:
	new_game()

func get_game_state_manager() -> GameStateManager:
	return game_state_manager

func get_buildable_structure_list() -> Array[StructureResource]:
	return game_state_manager.get_current_player_structure_manager().get_buildable_structure_list()

func get_game_resources_list() -> Array[GameResource]:
	return game_state_manager.get_current_player_game_resource_manager().get_game_resources_list()

func get_earnings_from_structure_building_completion(structure: StructureResource) -> Dictionary[String, float]:
	return game_state_manager.get_current_player_structure_manager().get_earnings_from_structure_building_completion(structure)

func get_current_player_resources() -> Dictionary[String, float]:
	return game_state_manager.get_current_player_resources()

func update_current_player_resource(game_resource_key: String, value: float) -> void:
	game_state_manager.update_current_player_resource(game_resource_key, value)

func _change_phase(new_phase: GamePhase) -> void:
	current_state = new_phase
	
	match current_state:
		GamePhase.SETUP_TURN:
			_setup_turn_phase()
			
		GamePhase.PLAYER_TURN:
			print("Waiting for player to act...")
			# Unlock UI buttons so the player can click things.
			# Notice how the code just STOPS here. It idles completely.

func _setup_turn_phase():
	print("Setting up the board...")
	
	cpu_player_wait_timer.start()
	await cpu_player_wait_timer.timeout
	
	var whitelisted_cities: Array[String] = [CITY_STRUCTURE_RESOURCE.name]
	emit_signal("buidable_structure_disabled", whitelisted_cities)
	emit_signal("player_turn_started")
	# Deal cards, spawn pieces, etc.
	# When finished, move to the next phase:
	_change_phase(GamePhase.PLAYER_TURN)

func new_game(number_of_players: int = 4):
	game_state_manager = GAME_STATE_MANAGER.instantiate()
	game_state_manager.current_game_resource_changed.connect(_on_current_game_resource_changed)
	add_child(game_state_manager)
	
	game_state_manager.setup(number_of_players)
	
	_change_phase(GamePhase.SETUP_TURN)

func on_structure_built(structure: StructureResource):
	game_state_manager.get_current_player_structure_manager().on_structure_built(structure)

func _on_current_game_resource_changed(game_resource_key: String, new_value: float):
	emit_signal("game_resource_changed", game_resource_key, new_value)
