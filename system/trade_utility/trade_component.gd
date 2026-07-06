class_name TradeComponent
extends HBoxContainer

@export var trade: TradeResource

@onready var acquiring_item_list_v_box_container: VBoxContainer = $AcquiringItemListVBoxContainer
@onready var giving_item_list_v_box_container: VBoxContainer = $GivingItemListVBoxContainer

const ACQUIRING_ITEM_COMPONENT_RESOURCE: Resource = preload("uid://i152whgpb360")
const GIVING_ITEM_COMPONENT_RESOURCE: Resource = preload("uid://bqcjhd0emm4pk")

func _ready() -> void:
	assert(trade, "No Trade provided!")
	_populate_item_list(ACQUIRING_ITEM_COMPONENT_RESOURCE, trade.acquired_items, acquiring_item_list_v_box_container)
	_populate_item_list(GIVING_ITEM_COMPONENT_RESOURCE, trade.given_items, giving_item_list_v_box_container)

func _populate_item_list(component: Resource, items: Array[TradeEntry], container: VBoxContainer) -> void:
	for trade_entry in items:
		var acquiring_item_component = component.instantiate()
		if acquiring_item_component is AcquiringItemComponent:
			acquiring_item_component.amount_changed.connect(_on_acquiring_item_component_amount_changed)
		acquiring_item_component.trade_entry = trade_entry
		container.add_child(acquiring_item_component)

func _on_acquiring_item_component_amount_changed(is_has_value_increased: bool, acquiring_item_component: AcquiringItemComponent):
	# add step to all other spinboxes
	for child: AcquiringItemComponent in acquiring_item_list_v_box_container.get_children():
		if not child == acquiring_item_component:
			child.add_step(is_has_value_increased)
	
	# increase values to all giving item list
	for child: GivingItemComponent in giving_item_list_v_box_container.get_children():
		child.add_step(is_has_value_increased)
