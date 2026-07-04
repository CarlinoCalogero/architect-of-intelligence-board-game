extends Node

enum GamePhase {
	SETUP_TURN,
	PLAYER_TURN
}

const GAME_STATE_MANAGER = preload("uid://bh1pyslmu1ara")

var game_state_manager: GameStateManager

func _ready() -> void:
	new_game()

func get_game_state_manager() -> GameStateManager:
	return game_state_manager

func new_game(number_of_players: int = 4):
	game_state_manager = GAME_STATE_MANAGER.instantiate()
	add_child(game_state_manager)
	
	game_state_manager.setup(number_of_players)
