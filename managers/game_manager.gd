extends Node

signal player_changed(new_player_index: int, player_color: PlayerColorResource)
signal local_player_turn_started
signal local_player_turn_ended
signal buidable_structure_disabled(structure_keys: Array[String])
signal game_resource_changed(game_resource_key: String, new_value: float)
signal build_structure_requested(player_index: int, structure_type: StructureResource)
signal dice_roll_requested(number_of_dice: int)
signal push_notification_requested(message: String, display_time: float)
signal hidden_dice_roll_requested(number_of_dice: int)

@onready var cpu_player_wait_timer: Timer = $CPUPlayerWaitTimer
@onready var cpu_player_manager: CPUPlayerManager = $CPUPlayerManager

enum GamePhase {
	MAIN_MENU,
	SETUP_TURN,
	PLAYER_TURN
}

enum SetupTurnPhaseSubphases {
	CITY_BUILDING,
	FIRST_PLANT_BUILDING,
	SECOND_PLANT_BUILDING,
	GENERATIVE_AI_BUILDING,
	RESOURCE_EARNINGS,
	KNOWLEDGE_CARDS_DRAW
}

const GAME_DEFINITION_RESOURCE: Resource = preload("uid://dso50mfa3p71h")
# -- MANAGER RESOURCES
const GAME_STATE_MANAGER: Resource = preload("uid://bh1pyslmu1ara")
# -- STRUCTURE RESOURCES
const CITY_STRUCTURE_RESOURCE: StructureResource = preload("uid://l2bs1modugmn")
const POWER_PLANT_STRUCTURE_RESOURCE: StructureResource = preload("uid://riyopulaq4d8")
const WATER_TREATMENT_PLANT_STRUCTURE_RESOURCE: StructureResource = preload("uid://dwgjxk7352pen")
const GENERATIVE_AI_NO_TIER_STRUCTURE_RESOURCE: StructureResource = preload("uid://cpqr0w0frd8mf")

var local_player_index: int = 0 # The actual player playing locally on the machine
var current_player_index: int = -1 # Must start at -1
var current_state: GamePhase = GamePhase.MAIN_MENU
var current_setup_turn_phase_subphases: SetupTurnPhaseSubphases = SetupTurnPhaseSubphases.CITY_BUILDING

var setup_phase_production_queue: Array[GameResourceFormula] = []

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

func update_current_player_resource(game_resource: GameResource, value: float) -> void:
	game_state_manager.update_player_resource(current_player_index, game_resource, value)

func add_current_player_built_structure(structure: StructureResource, cell: Vector2i) -> bool:
	return game_state_manager.add_built_structure(current_player_index, structure, cell)

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
			_current_setup_turn_phase_city_building_subphases()
			return
		
		SetupTurnPhaseSubphases.FIRST_PLANT_BUILDING:
			_current_setup_turn_phase_first_plant_building_subphases()
			return
		
		SetupTurnPhaseSubphases.SECOND_PLANT_BUILDING:
			_current_setup_turn_phase_second_plant_building_subphases()
			return
		
		SetupTurnPhaseSubphases.GENERATIVE_AI_BUILDING:
			_current_setup_turn_phase_generative_ai_no_tier_building_subphases()
			return
		
		SetupTurnPhaseSubphases.RESOURCE_EARNINGS:
			if setup_phase_production_queue.is_empty():
				setup_phase_production_queue = game_state_manager.get_player_setup_phase_production_earning_queue(current_player_index)
			var dice_amount: int = setup_phase_production_queue.front().number_of_dice_to_roll
			if current_player_index == local_player_index:
				emit_signal("dice_roll_requested", dice_amount)
			else:
				cpu_player_manager.cpu_player_rolls_dice(current_player_index, dice_amount)
			return
		
		SetupTurnPhaseSubphases.KNOWLEDGE_CARDS_DRAW:
			return
		
	# Deal cards, spawn pieces, etc.
	# When finished, move to the next phase:
	_change_phase(GamePhase.PLAYER_TURN)

func _current_setup_turn_phase_city_building_subphases():
	_setup_turn_phase_building_subphase([CITY_STRUCTURE_RESOURCE.name], CITY_STRUCTURE_RESOURCE)

func _current_setup_turn_phase_first_plant_building_subphases():
	_setup_turn_phase_building_subphase([POWER_PLANT_STRUCTURE_RESOURCE.name, WATER_TREATMENT_PLANT_STRUCTURE_RESOURCE.name], [POWER_PLANT_STRUCTURE_RESOURCE, WATER_TREATMENT_PLANT_STRUCTURE_RESOURCE].pick_random(), "Plant")

func _current_setup_turn_phase_second_plant_building_subphases():
	var last_player_built_structure: StructureResource = game_state_manager.get_player_last_built_structure_type(current_player_index)
	var structure_to_be_built: StructureResource = POWER_PLANT_STRUCTURE_RESOURCE
	if POWER_PLANT_STRUCTURE_RESOURCE.name == last_player_built_structure.name:
		structure_to_be_built = WATER_TREATMENT_PLANT_STRUCTURE_RESOURCE
	_setup_turn_phase_building_subphase([structure_to_be_built.name], structure_to_be_built)

func _current_setup_turn_phase_generative_ai_no_tier_building_subphases():
	_setup_turn_phase_building_subphase([GENERATIVE_AI_NO_TIER_STRUCTURE_RESOURCE.name], GENERATIVE_AI_NO_TIER_STRUCTURE_RESOURCE)

func _setup_turn_phase_building_subphase(whitelisted_structures: Array[String], cpu_player_structure_resource_to_be_built: StructureResource, text_log: String = cpu_player_structure_resource_to_be_built.name):
	if current_player_index == local_player_index:
		print("Waiting for local player to build a [", text_log, "]...")
		emit_signal("buidable_structure_disabled", whitelisted_structures)
		emit_signal("local_player_turn_started")
	else:
		print("[", get_current_player_color().name, "] is placing a  [", text_log, "], please wait...")
		cpu_player_manager.cpu_player_builds_structure(current_player_index, cpu_player_structure_resource_to_be_built)

func new_game(number_of_players: int = 4):
	if number_of_players > game_definition.get_max_number_of_players():
		return
	
	game_state_manager = GAME_STATE_MANAGER.instantiate()
	game_state_manager.current_game_resource_changed.connect(_on_current_game_resource_changed)
	add_child(game_state_manager)
	
	var player_colors: Array[PlayerColorResource] = game_definition.get_player_colors()
	game_state_manager.setup(player_colors, get_game_resources_list())
	
	_change_phase(GamePhase.SETUP_TURN)

func on_structure_built(structure: StructureResource, cell_position: Vector2i):
	add_current_player_built_structure(structure, cell_position)
	
	if current_state == GamePhase.SETUP_TURN:
		match current_setup_turn_phase_subphases:
			SetupTurnPhaseSubphases.CITY_BUILDING:
				_on_structure_built_next_setup_turn_phase(SetupTurnPhaseSubphases.FIRST_PLANT_BUILDING)
				return
			
			SetupTurnPhaseSubphases.FIRST_PLANT_BUILDING:
				_on_structure_built_next_setup_turn_phase(SetupTurnPhaseSubphases.SECOND_PLANT_BUILDING)
				return
			
			SetupTurnPhaseSubphases.SECOND_PLANT_BUILDING:
				_on_structure_built_next_setup_turn_phase(SetupTurnPhaseSubphases.GENERATIVE_AI_BUILDING)
				return
			
			SetupTurnPhaseSubphases.GENERATIVE_AI_BUILDING:
				_on_structure_built_next_setup_turn_phase(SetupTurnPhaseSubphases.RESOURCE_EARNINGS)
				return

func _on_structure_built_next_setup_turn_phase(next_phase: SetupTurnPhaseSubphases):
	if current_player_index == local_player_index:
		emit_signal("local_player_turn_ended")
	elif current_player_index == game_state_manager.get_number_of_players() - 1:
		current_setup_turn_phase_subphases = next_phase
	_setup_turn_phase()

func _on_current_game_resource_changed(game_resource: GameResource, new_value: float):
	emit_signal("game_resource_changed", game_resource, new_value)
	# miao
	var player_text: String = "You have"
	if local_player_index != current_player_index:
		var player_color: PlayerColorResource = game_state_manager.get_player_color(current_player_index)
		player_text = str(player_color.name) + " has"
	var notification_text: String = player_text + " earned " + str(new_value) + " " + str(game_resource.unit_of_measurement)
	emit_signal("push_notification_requested", notification_text)

func _on_cpu_player_manager_build_structure_requested(player_index: int, structure_type: StructureResource) -> void:
	emit_signal("build_structure_requested", player_index, structure_type)

func on_dice_rolled(rolls: Array[int]):
	emit_signal("push_notification_requested", "Rolled: " + str(rolls))
	
	if current_state == GamePhase.SETUP_TURN:
		match current_setup_turn_phase_subphases:
			SetupTurnPhaseSubphases.RESOURCE_EARNINGS:
				_on_dice_rollet_next_setup_turn_phase(rolls, SetupTurnPhaseSubphases.KNOWLEDGE_CARDS_DRAW)

func _on_dice_rollet_next_setup_turn_phase(rolls: Array[int], next_phase: SetupTurnPhaseSubphases):
	var setup_phase_production_formula: GameResourceFormula = setup_phase_production_queue.pop_front()
	var dice_sum: int = rolls.reduce(func(accum, number): return accum + number, 0)
	var new_value: float = setup_phase_production_formula.base_value + (dice_sum * setup_phase_production_formula.multiplier_value)
	update_current_player_resource(setup_phase_production_formula.resource_type, new_value)
	
	if not setup_phase_production_queue.is_empty():
		var dice_amount: int = setup_phase_production_queue.front().number_of_dice_to_roll
		if current_player_index == local_player_index:
			emit_signal("dice_roll_requested", dice_amount)
		else:
			cpu_player_manager.cpu_player_rolls_dice(current_player_index, dice_amount)
		return # this is important here
	
	var is_last_player: bool = current_player_index == (game_state_manager.get_number_of_players() - 1)
	if is_last_player:
		current_setup_turn_phase_subphases = next_phase
	
	_setup_turn_phase()

func _on_cpu_player_manager_roll_dice_requested(_player_index: int, dice_amount: int) -> void:
	emit_signal("hidden_dice_roll_requested", dice_amount)
