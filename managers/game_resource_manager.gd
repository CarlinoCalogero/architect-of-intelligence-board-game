class_name GameResourceManager
extends Resource

var game_resources: Array[GameResource]

func _init(new_game_resources: Array[GameResource]) -> void:
	game_resources = new_game_resources

func get_game_resources_list() -> Array[GameResource]:
	return game_resources
