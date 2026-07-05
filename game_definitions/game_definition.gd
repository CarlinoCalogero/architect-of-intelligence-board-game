class_name GameDefinition
extends Node

var game_resources: Array[GameResource] = []
var structures: Array[StructureResource] = []
var player_colors: Array[PlayerColorResource] = []
var knowledge_cards: Array[KnowledgeCardResource] = []

const BASE_RESOURCES_FOLDER_PATH: String = "res://definitions/"
const GAME_RESOURCE_FOLDER: String = "game_resources"
const STRUCTURE_RESOURCE_FOLDER: String = "structure_resources"
const PLAYER_COLOR_RESOURCE_FOLDER: String = "player_colors"
const KNOWLEDGE_CARDS_RESOURCE_FOLDER: String = "knowledge_cards"

func _ready() -> void:
	_load_all_game_resource_resources_from_folder()
	_load_all_structure_resources_from_folder()
	_load_all_player_color_resources_from_folder()
	_load_all_knowledge_cards_resources_from_folder()

func _load_all_game_resource_resources_from_folder():
	_load_resources_from_folder(GAME_RESOURCE_FOLDER, game_resources)

func _load_all_structure_resources_from_folder():
	_load_resources_from_folder(STRUCTURE_RESOURCE_FOLDER, structures)

func _load_all_player_color_resources_from_folder():
	_load_resources_from_folder(PLAYER_COLOR_RESOURCE_FOLDER, player_colors)

func _load_all_knowledge_cards_resources_from_folder():
	_load_resources_from_folder(KNOWLEDGE_CARDS_RESOURCE_FOLDER, knowledge_cards)

func _load_resources_from_folder(folder_name: String, resource_variable: Array) -> void:
	# Open the folder
	var path: String = BASE_RESOURCES_FOLDER_PATH + folder_name + "/"
	var dir = DirAccess.open(path)
	
	if dir != null:
		# Get a list of every file inside that folder
		var files = dir.get_files()
		
		# Cycle through them one by one
		for file_name in files:
			
			# (See the Pro-Tip below about this .remap line!)
			var clean_name = file_name.trim_suffix(".remap")
			
			# Only load .tres files (ignore things like imported images or hidden files)
			if clean_name.ends_with(".tres"):
				# Build the full path (e.g., "res://game_resources/gold.tres")
				var full_path = path + clean_name
				
				# Load it and cast it
				var loaded_res = load(full_path)
				
				# If it successfully loaded as a GameResource, add it to our array!
				if loaded_res != null:
					resource_variable.append(loaded_res)
		
		print("Loaded ", resource_variable.size(), " resources dynamically!")
	else:
		print("Error: Could not open folder at ", path)

# -- GETTERS

func get_buildable_structures() -> Array[StructureResource]:
	return structures

func get_game_resources() -> Array[GameResource]:
	return game_resources

func get_player_colors() -> Array[PlayerColorResource]:
	return player_colors

func get_max_number_of_players() -> int:
	return player_colors.size()
