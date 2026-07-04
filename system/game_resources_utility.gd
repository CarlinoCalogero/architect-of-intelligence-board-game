class_name GameResourcesUtility
extends Control

@onready var item_list: ItemList = $ItemList

var game_resource_indexes: Dictionary[String, int] = {}

func _ready():
	GameManager.game_resource_changed.connect(_update_game_resource)
	_populate_item_list()

func _populate_item_list():
	item_list.clear()
	var player_resources: Dictionary[String, float] = GameManager.get_local_player_resources()
	for game_resource: GameResource in GameManager.get_game_resources_list():
		var item_index: int = item_list.add_item(str(player_resources[game_resource.name]), game_resource.icon)
		game_resource_indexes[game_resource.name] = item_index

func _update_game_resource(_game_resource_key: String, _new_value: float):
	_populate_item_list()
