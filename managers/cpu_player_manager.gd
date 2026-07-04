class_name CPUPlayerManager
extends Node

signal build_structure_requested(player_index: int, structure_type: StructureResource)

func cpu_player_builds_structure(player_index: int, structure_type: StructureResource):
	emit_signal("build_structure_requested", player_index, structure_type)
