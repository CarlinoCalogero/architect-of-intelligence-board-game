extends Node

signal player_changed(new_player_index: int, player_color: PlayerColorResource)
signal local_player_turn_started
signal local_player_turn_ended
signal buidable_structure_disabled(structure_keys: Array[String])
signal game_resource_changed(game_resource_key: String, new_value: float)

@onready var cpu_player_wait_timer: Timer = $CPUPlayerWaitTimer

enum GamePhase {
	MAIN_MENU,
	SETUP_TURN,
	PLAYER_TURN
}

enum SetupTurnPhaseSubphases {
	CITY_BUILDING,
}

const GAME_DEFINITION_RESOURCE: Resource = preload("uid://dso50mfa3p71h")
# -- MANAGER RESOURCES
const GAME_STATE_MANAGER: Resource = preload("uid://bh1pyslmu1ara")
# -- STRUCTURE RESOURCES
const CITY_STRUCTURE_RESOURCE: StructureResource = preload("uid://l2bs1modugmn")

var local_player_index: int = 0 # The actual player playing locally on the machine
var current_player_index: int = -1 # Must start at -1
var current_state: GamePhase = GamePhase.MAIN_MENU
var current_setup_turn_phase_subphases: SetupTurnPhaseSubphases = SetupTurnPhaseSubphases.CITY_BUILDING

var game_definition: GameDefinition

# -- MANAGERS
var game_state_manager: GameStateManager

func _ready() -> void:
	game_definition = GAME_DEFINITION_RESOURCE.instantiate()
	add_child(game_definition)
	
	new_game()

func get_game_state_manager() -> GameStateManager:
	return game_state_manager

# -- GAME DEFINITION FUNCTIONS

func get_game_resources_list() -> Array[GameResource]:
	return game_definition.get_game_resources()

func get_buildable_structure_list() -> Array[StructureResource]:
	return game_definition.get_buildable_structures()

# -- LOCAL PLAYER FUNCTIONS

func get_local_player_resources() -> Dictionary[String, float]:
	return game_state_manager.get_player_resources(local_player_index)

# -- CURRENT PLAYER FUNCTIONS

func get_current_player_color() -> PlayerColorResource:
	return game_state_manager.get_player_color(current_player_index)

func get_current_player_resources() -> Dictionary[String, float]:
	return game_state_manager.get_player_resources(current_player_index)

func update_current_player_resource(game_resource_key: String, value: float) -> void:
	game_state_manager.update_player_resource(current_player_index, game_resource_key, value)

func check_if_current_player_has_built_all_structures_of_type(structure: StructureResource) -> bool:
	return game_state_manager.check_if_player_has_built_all_structures_of_type(current_player_index, structure)

# -- GAME FLOW FUNCTIONS

func _compute_next_player_index():
	current_player_index = (current_player_index + 1) % game_state_manager.get_number_of_players()
	var current_player_color: PlayerColorResource = game_state_manager.get_player_color(current_player_index)
	emit_signal("player_changed", current_player_index, current_player_color)
	print("New Turn for Player: [", current_player_color.name, "], at index: [", current_player_index, "]")

func _change_phase(new_phase: GamePhase) -> void:
	current_state = new_phase
	
	match current_state:
		GamePhase.SETUP_TURN:
			print("Setting up the board...")
			_setup_turn_phase()
			return
			
		GamePhase.PLAYER_TURN:
			print("Waiting for player to act...")
			# Unlock UI buttons so the player can click things.
			# Notice how the code just STOPS here. It idles completely.
			return

func _setup_turn_phase():
	# Remove later
	cpu_player_wait_timer.start()
	await cpu_player_wait_timer.timeout
	# Remove later
	
	_compute_next_player_index()
	
	match current_setup_turn_phase_subphases:
		SetupTurnPhaseSubphases.CITY_BUILDING:
			_current_setup_turn_phase_player_city_building_subphases()
			return
		
	# Deal cards, spawn pieces, etc.
	# When finished, move to the next phase:
	_change_phase(GamePhase.PLAYER_TURN)

func _current_setup_turn_phase_player_city_building_subphases():
	
	if current_player_index == local_player_index:
		print("Waiting for local player to build a City...")
		var whitelisted_cities: Array[String] = [CITY_STRUCTURE_RESOURCE.name]
		emit_signal("buidable_structure_disabled", whitelisted_cities)
		emit_signal("local_player_turn_started")
	else:
		print("[", get_current_player_color().name, "] is placing a City, please wait...")

func new_game(number_of_players: int = 4):
	if number_of_players > game_definition.get_max_number_of_players():
		return
	
	game_state_manager = GAME_STATE_MANAGER.instantiate()
	game_state_manager.current_game_resource_changed.connect(_on_current_game_resource_changed)
	add_child(game_state_manager)
	
	var player_colors: Array[PlayerColorResource] = game_definition.get_player_colors()
	game_state_manager.setup(player_colors, get_game_resources_list())
	
	_change_phase(GamePhase.SETUP_TURN)

func on_structure_built(structure: StructureResource):
	check_if_current_player_has_built_all_structures_of_type(structure)
	
	if current_state == GamePhase.SETUP_TURN:
		match current_setup_turn_phase_subphases:
			
			SetupTurnPhaseSubphases.CITY_BUILDING:
				if current_player_index == local_player_index:
					emit_signal("local_player_turn_ended")
				_setup_turn_phase()
				return

func _on_current_game_resource_changed(game_resource_key: String, new_value: float):
	emit_signal("game_resource_changed", game_resource_key, new_value)
