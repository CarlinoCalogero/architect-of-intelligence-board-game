class_name DiceRollUtility
extends Control

@onready var button: Button = $CenterContainer/Button

var number_of_dice_to_roll: int = 0

func _ready() -> void:
	self.hide()
	
	GameManager.dice_roll_requested.connect(_on_dice_roll_requested)

func roll(number_of_dice: int):
	number_of_dice_to_roll = number_of_dice
	button.text = "Click to roll " + str(number_of_dice) + " dice!"
	print("marco")
	self.show()

func roll_dice(number_of_dice: int) -> Array[int]:
	var results: Array[int] = []
	
	for i in range(number_of_dice):
		# randi_range is inclusive, so it will pick 1, 2, 3, 4, 5, or 6
		results.append(randi_range(1, 6))
	
	return results

func _on_button_pressed() -> void:
	print("Button was pressed!")
	self.hide()
	_on_dice_rolled(roll_dice(number_of_dice_to_roll))

func _on_dice_roll_requested(number_of_dice: int):
	print("pecora")
	roll(number_of_dice)

func _on_dice_rolled(rolls: Array[int]):
	GameManager.on_dice_rolled(rolls)
