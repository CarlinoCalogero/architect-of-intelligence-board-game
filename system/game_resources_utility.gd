class_name GameResourcesUtility
extends Control

@onready var game_state_manager: GameStateManager = GameManager.get_game_state_manager()
@onready var item_list: ItemList = $ItemList

var game_resource_indexes: Dictionary[String, int] = {}

func _ready():
	assert(game_state_manager, "No Game State Manager")
	game_state_manager.current_game_resource_changed.connect(_update_game_resource)
	_populate_item_list()

func _populate_item_list():
	item_list.clear()
	var player_resources: Dictionary[String, float] = game_state_manager.get_current_player_resources()
	for game_resource: GameResource in game_state_manager.get_current_player_game_resource_manager().get_game_resources_list():
		var item_index: int = item_list.add_item(str(player_resources[game_resource.name]), game_resource.icon)
		game_resource_indexes[game_resource.name] = item_index

func _update_game_resource(game_resource_key: String, new_value: float):
	item_list.set_item_text(game_resource_indexes[game_resource_key], str(new_value))
