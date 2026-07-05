class_name CPUPlayerManager
extends Node

signal build_structure_requested(player_index: int, structure_type: StructureResource)
signal roll_dice_requested(player_index: int, dice_amount: int)

func cpu_player_builds_structure(player_index: int, structure_type: StructureResource):
	emit_signal("build_structure_requested", player_index, structure_type)

func cpu_player_rolls_dice(player_index: int, dice_amount: int):
	emit_signal("roll_dice_requested", player_index, dice_amount)
