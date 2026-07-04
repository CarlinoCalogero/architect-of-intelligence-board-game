class_name GameResourceManager
extends Resource

var game_resources: Array[GameResource]
var current_resources: Dictionary[String, float]

func _init(new_game_resources: Array[GameResource]) -> void:
	game_resources = new_game_resources
	_set_up_current_resources()

func get_game_resources_list() -> Array[GameResource]:
	return game_resources

func get_current_resources() -> Dictionary[String, float]:
	return current_resources

func update_current_resource(resource_key: String, amount: float) -> float:
	current_resources[resource_key] += amount
	return current_resources[resource_key]

func _set_up_current_resources():
	for game_resource in game_resources:
		current_resources[game_resource.name] = 0.0
