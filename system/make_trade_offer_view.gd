class_name MakeTradeOfferView
extends Control

@onready var trade_entries_v_box_container: VBoxContainer = $TradesListVBoxContainer/MarginContainer/ScrollContainer/TradeEntriesVBoxContainer

const TRADE_COMPONENT_RESOURCE: Resource = preload("uid://cnwigumvxhaxm")

func _ready():
	_setup_make_trade_view()

func _setup_make_trade_view():
	var trades: Array[TradeResource] = GameManager.get_trades_list()
	for trade in trades:
		var trade_component: TradeComponent = TRADE_COMPONENT_RESOURCE.instantiate()
		trade_component.trade = trade
		trade_entries_v_box_container.add_child(trade_component)
