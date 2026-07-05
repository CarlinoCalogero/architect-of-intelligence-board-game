class_name DiceRollUtility
extends Control

@onready var button: Button = $CenterContainer/Button

var number_of_dice_to_roll: int = 0

func _ready() -> void:
	self.hide()
	
	GameManager.dice_roll_requested.connect(_on_dice_roll_requested)
	GameManager.hidden_dice_roll_requested.connect(_on_hidden_dice_roll_requested)
	GameManager.set_ui_button_disabled_requested.connect(_on_set_ui_button_disabled_requested)

func roll_dice(number_of_dice: int) -> Array[int]:
	var results: Array[int] = []
	
	for i in range(number_of_dice):
		# randi_range is inclusive, so it will pick 1, 2, 3, 4, 5, or 6
		results.append(randi_range(1, 6))
	
	return results

func _roll(number_of_dice: int):
	number_of_dice_to_roll = number_of_dice
	button.text = "Click to roll " + str(number_of_dice) + " dice!"
	self.show()

func _do_roll():
	var rolls: Array[int] = roll_dice(number_of_dice_to_roll)
	GameManager.on_dice_rolled(rolls)

func _set_utility_disabled(is_disabled: bool):
	self.visible = is_disabled

func _on_button_pressed() -> void:
	self.hide() # this is important here
	_do_roll()

func _on_dice_roll_requested(number_of_dice: int):
	_roll(number_of_dice)

func _on_hidden_dice_roll_requested(number_of_dice: int):
	number_of_dice_to_roll = number_of_dice
	_do_roll()

func _on_set_ui_button_disabled_requested(is_disabled: bool):
	_set_utility_disabled(is_disabled)
