extends Node

signal player_changed(new_player_index: int, player_color: PlayerColorResource)
signal set_build_utility_disabled_requested(is_disabled: bool)
signal buidable_structure_disabled(structure_keys: Array[String])
signal enable_all_buildable_structures
signal game_resource_changed(game_resource: GameResource, new_value: float)
signal build_structure_requested(structure_type: StructureResource)
signal dice_roll_requested(number_of_dice: int)
signal push_notification_requested(message: String, display_time: float)
signal hidden_dice_roll_requested(number_of_dice: int)
signal knowledge_card_changed
signal toggle_knowledge_card_desk_requested(is_visible: bool)
signal set_knowledge_card_desk_close_button_disabled_requested(is_disabled: bool)
signal set_ui_button_disabled_requested(is_disabled: bool)

@onready var cpu_player_wait_timer: Timer = $CPUPlayerWaitTimer
@onready var turn_manager: TurnManager = $TurnManager

enum GamePhase {
	MAIN_MENU,
	SETUP_TURN,
	PLAYING
}

enum SetupTurnPhaseSubphases {
	CITY_BUILDING,
	FIRST_PLANT_BUILDING,
	SECOND_PLANT_BUILDING,
	GENERATIVE_AI_BUILDING,
	RESOURCE_EARNINGS,
	KNOWLEDGE_CARDS_DRAW,
	SETUP_COMPLETED
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

func get_knowledge_cards_list() -> Array[KnowledgeCardResource]:
	return game_definition.get_knowledge_cards()

func get_max_number_of_players() -> int:
	return game_definition.get_max_number_of_players()

func get_max_number_of_knowledge_cards() -> int:
	return game_definition.get_max_number_of_knowledge_cards()

# -- LOCAL PLAYER FUNCTIONS

func get_local_player_resources() -> Dictionary[String, float]:
	return game_state_manager.get_player_resources(local_player_index)

func get_local_player_knowledge_cards() -> Array[KnowledgeCardResource]:
	return game_state_manager.get_player_knowledge_cards(local_player_index)

func is_local_player_playing() -> bool:
	return current_player_index == local_player_index

# -- CURRENT PLAYER FUNCTIONS

func get_current_player_color() -> PlayerColorResource:
	return game_state_manager.get_player_color(current_player_index)

func get_current_player_resources() -> Dictionary[String, float]:
	return game_state_manager.get_player_resources(current_player_index)

func get_current_player_resource_from_key(resource_key: String) -> float:
	return game_state_manager.get_player_resources_from_key(current_player_index, resource_key)

func get_current_player_knowledge_cards() -> Array[KnowledgeCardResource]:
	return game_state_manager.get_player_knowledge_cards(current_player_index)

func get_current_player_built_structure() -> Dictionary[String, Array]:
	return game_state_manager.get_player_built_structures(current_player_index)

func is_current_player_last_player() -> bool:
	return current_player_index == (game_state_manager.get_number_of_players() - 1)

func update_current_player_resource(game_resource: GameResource, value: float, producing_structure_built_data: BuiltData = null) -> float:
	return game_state_manager.update_player_resource(current_player_index, game_resource, value, producing_structure_built_data)

func add_current_player_built_structure(structure: StructureResource, cell: Vector2i) -> bool:
	return game_state_manager.add_built_structure(current_player_index, structure, cell)

func draw_random_knowledge_card() -> void:
	var knowledge_card_list: Array[KnowledgeCardResource] = get_knowledge_cards_list()
	var owned_knowledge_cards: Array[KnowledgeCardResource] = get_current_player_knowledge_cards()
	var max_number_of_knowledge_cards: int = get_max_number_of_knowledge_cards()
	
	# First, check if the player is even allowed to draw a card
	if owned_knowledge_cards.size() >= max_number_of_knowledge_cards:
		print("Player's hand is full!")
		return
		
	# Create a new array to hold only the cards the player doesn't have
	var available_cards: Array[KnowledgeCardResource] = []
	
	for card in knowledge_card_list:
		# If the owned list DOES NOT have this card, it's safe to draw
		if not owned_knowledge_cards.has(card):
			available_cards.append(card)
			
	# Make sure there are actually cards left to draw!
	if available_cards.is_empty():
		print("No more unique cards left to draw!")
		return
		
	# Pick a random card from the available pool
	var picked_card: KnowledgeCardResource = available_cards.pick_random()
	
	# Add it to the player's inventory
	game_state_manager.add_player_knowledge_card(current_player_index, picked_card)
	emit_signal("knowledge_card_changed")

# GAME UI FUNCTIONS

func disable_ui_buttons():
	emit_signal("set_ui_button_disabled_requested", true)

func enable_ui_buttons():
	emit_signal("set_ui_button_disabled_requested", false)

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
			
		GamePhase.PLAYING:
			print("Starting game...")
			turn_manager.start_game_session()
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
			roll_dice(dice_amount)
			return
		
		SetupTurnPhaseSubphases.KNOWLEDGE_CARDS_DRAW:
			var max_number_of_knowledge_cards: int = get_max_number_of_knowledge_cards()
			var is_local_player: bool = current_player_index == local_player_index
			
			if is_local_player:
					emit_signal("toggle_knowledge_card_desk_requested", true)
					emit_signal("set_knowledge_card_desk_close_button_disabled_requested", true)
			
			for index in range(max_number_of_knowledge_cards):
				if is_local_player:
					print("Drawing the knowledge card [", index, "] for the local player, please wait...")
				else:
					var notification_text: String = "Drawing the knowledge card [" + str(index + 1) + "] for player [" + get_current_player_color().name + "], please wait..."
					emit_signal("push_notification_requested", notification_text)
				
				cpu_player_wait_timer.start()
				await cpu_player_wait_timer.timeout
				
				draw_random_knowledge_card()
			
			if is_local_player:
				emit_signal("set_knowledge_card_desk_close_button_disabled_requested", false)
			else:
				if is_current_player_last_player():
					current_setup_turn_phase_subphases = SetupTurnPhaseSubphases.SETUP_COMPLETED
				_setup_turn_phase()
			return
		
		SetupTurnPhaseSubphases.SETUP_COMPLETED:
			print("Board setup successfully completed...")
			_change_phase(GamePhase.PLAYING)
			return

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
		emit_signal("set_build_utility_disabled_requested", false)
	else:
		print("[", get_current_player_color().name, "] is placing a  [", text_log, "], please wait...")
		emit_signal("build_structure_requested", cpu_player_structure_resource_to_be_built)

func new_game(number_of_players: int = 4):
	if number_of_players > get_max_number_of_players():
		return
	
	game_state_manager = GAME_STATE_MANAGER.instantiate()
	game_state_manager.current_game_resource_changed.connect(_on_current_game_resource_changed)
	add_child(game_state_manager)
	
	var player_colors: Array[PlayerColorResource] = game_definition.get_player_colors()
	game_state_manager.setup(player_colors, get_game_resources_list())
	
	_change_phase(GamePhase.SETUP_TURN)

func on_structure_built(structure: StructureResource, cell_position: Vector2i) -> bool:
	var is_was_structure_building_limit_reached: bool = add_current_player_built_structure(structure, cell_position)
	
	if current_state == GamePhase.SETUP_TURN:
		match current_setup_turn_phase_subphases:
			SetupTurnPhaseSubphases.CITY_BUILDING:
				_on_structure_built_next_setup_turn_phase(SetupTurnPhaseSubphases.FIRST_PLANT_BUILDING)
				return is_was_structure_building_limit_reached
			
			SetupTurnPhaseSubphases.FIRST_PLANT_BUILDING:
				_on_structure_built_next_setup_turn_phase(SetupTurnPhaseSubphases.SECOND_PLANT_BUILDING)
				return is_was_structure_building_limit_reached
			
			SetupTurnPhaseSubphases.SECOND_PLANT_BUILDING:
				_on_structure_built_next_setup_turn_phase(SetupTurnPhaseSubphases.GENERATIVE_AI_BUILDING)
				return is_was_structure_building_limit_reached
			
			SetupTurnPhaseSubphases.GENERATIVE_AI_BUILDING:
				_on_structure_built_next_setup_turn_phase(SetupTurnPhaseSubphases.RESOURCE_EARNINGS)
				if current_setup_turn_phase_subphases == SetupTurnPhaseSubphases.RESOURCE_EARNINGS:
					emit_signal("enable_all_buildable_structures")
				return is_was_structure_building_limit_reached
	
	return is_was_structure_building_limit_reached

func _on_structure_built_next_setup_turn_phase(next_phase: SetupTurnPhaseSubphases):
	if current_player_index == local_player_index:
		emit_signal("set_build_utility_disabled_requested", true)
	elif is_current_player_last_player():
		current_setup_turn_phase_subphases = next_phase
	_setup_turn_phase()

func _on_current_game_resource_changed(game_resource: GameResource, new_value: float):
	emit_signal("game_resource_changed", game_resource, new_value)
	var player_text: String = "You have"
	if local_player_index != current_player_index:
		var player_color: PlayerColorResource = game_state_manager.get_player_color(current_player_index)
		player_text = str(player_color.name) + " has"
	var unit_of_measurement: String = str(game_resource.unit_of_measurement)
	if unit_of_measurement.is_empty():
		unit_of_measurement = game_resource.name
	var notification_text: String = player_text + " now " + str(new_value) + " " + unit_of_measurement
	emit_signal("push_notification_requested", notification_text)

func on_dice_rolled(rolls: Array[int]):
	emit_signal("push_notification_requested", "Rolled: " + str(rolls))
	
	if current_state == GamePhase.SETUP_TURN:
		match current_setup_turn_phase_subphases:
			SetupTurnPhaseSubphases.RESOURCE_EARNINGS:
				_on_dice_rolled_next_setup_turn_phase(rolls, SetupTurnPhaseSubphases.KNOWLEDGE_CARDS_DRAW)
	
	if current_state == GamePhase.PLAYING:
		turn_manager.dice_rolled(rolls)

func _on_dice_rolled_next_setup_turn_phase(rolls: Array[int], next_phase: SetupTurnPhaseSubphases):
	var setup_phase_production_formula: GameResourceFormula = setup_phase_production_queue.pop_front()
	var dice_sum: int = rolls.reduce(func(accum, number): return accum + number, 0)
	var new_value: float = setup_phase_production_formula.formula_sign * (setup_phase_production_formula.base_value + (dice_sum * setup_phase_production_formula.multiplier_value))
	update_current_player_resource(setup_phase_production_formula.resource_type, new_value)
	
	if not setup_phase_production_queue.is_empty():
		var dice_amount: int = setup_phase_production_queue.front().number_of_dice_to_roll
		roll_dice(dice_amount)
		return # this is important here
	
	if is_current_player_last_player():
		current_setup_turn_phase_subphases = next_phase
	
	_setup_turn_phase()

func on_knowledge_card_desk_closed():
	if current_state == GamePhase.SETUP_TURN:
		match current_setup_turn_phase_subphases:
			SetupTurnPhaseSubphases.KNOWLEDGE_CARDS_DRAW:
				_setup_turn_phase()

func roll_dice(dice_amount: int):
	if current_player_index == local_player_index:
		emit_signal("dice_roll_requested", dice_amount)
	else:
		emit_signal("hidden_dice_roll_requested", dice_amount)
