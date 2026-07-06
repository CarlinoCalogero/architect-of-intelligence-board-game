class_name GivingItemComponent
extends HBoxContainer

@export var trade_entry: TradeEntry

@onready var item_icon_texture_rect: TextureRect = $ItemIconTextureRect
@onready var amount_label: Label = $CenterContainer/AmountLabel

const PADDING: int = 45
var is_card: bool = false
var current_amount: int = 0

func _ready() -> void:
	assert(trade_entry, "No trade entry provided!")
	_setup()

func _setup():
	if trade_entry.card:
		is_card = true
	if trade_entry.game_resource:
		is_card = false
	_setup_texture()
	_setup_amount_label(0)

func _setup_texture():
	var new_texture: Texture2D = null
	if is_card:
		new_texture = trade_entry.card.icon
	else:
		new_texture = trade_entry.game_resource.icon
	item_icon_texture_rect.texture = new_texture

func _setup_amount_label(new_amount: int):
	var unit_of_measurement = ""
	if is_card:
		unit_of_measurement = trade_entry.card.name
	else:
		var game_resource: GameResource = trade_entry.game_resource
		unit_of_measurement = game_resource.unit_of_measurement
		if not unit_of_measurement:
			unit_of_measurement = game_resource.name
	current_amount = new_amount
	amount_label.text = str(current_amount) + " " + unit_of_measurement

func add_step(is_increase: bool):
	var multiplier: int = 1
	if not is_increase:
		multiplier *= -1
	var new_amount: int = current_amount + (multiplier * trade_entry.amount)
	_setup_amount_label(new_amount)
