class_name AcquiringItemComponent
extends HBoxContainer

signal amount_changed(is_has_value_increased: bool, acquiring_item_component: AcquiringItemComponent)

@export var trade_entry: TradeEntry

@onready var item_icon_texture_rect: TextureRect = $ItemIconTextureRect
@onready var amount_spin_box: SpinBox = $CenterContainer/AmountSpinBox

const PADDING: int = 45
var previous_value: float = 0

func _ready() -> void:
	assert(trade_entry, "No trade entry provided!")
	_setup_texture()
	_setup_spinbox()

func _setup_texture():
	var new_texture: Texture2D = null
	if trade_entry.card:
		new_texture = trade_entry.card.icon
	if trade_entry.game_resource:
		new_texture = trade_entry.game_resource.icon
	item_icon_texture_rect.texture = new_texture

func _setup_spinbox():
	amount_spin_box.step = trade_entry.amount
	amount_spin_box.min_value = 0

func _resize_amount_spinbox():
	var line_edit: LineEdit = amount_spin_box.get_line_edit()
	var current_text: String = line_edit.text
	
	var font: Font = line_edit.get_theme_font("font")
	var font_size: int = line_edit.get_theme_font_size("font_size")
	
	var text_width: float = font.get_string_size(current_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	
	amount_spin_box.custom_minimum_size.x = text_width + PADDING

func add_step(is_increase: bool):
	var multiplier: int = 1
	if not is_increase:
		multiplier *= -1
	amount_spin_box.value += multiplier * trade_entry.amount

func _on_amount_spin_box_value_changed(value: float) -> void:
	_resize_amount_spinbox()
	var is_has_value_increased: bool = previous_value < value
	previous_value = value
	emit_signal("amount_changed", is_has_value_increased, self)
