class_name KnowledgeCardUtility
extends Control

@onready var open_knowledge_cards_desk_button: Button = $OpenKnowledgeCardsDeskButton
@onready var knowledge_cards_desk: Control = $KnowledgeCardsDesk
@onready var knowledge_card_components: Array[KnowledgeCardComponent] = [
	$KnowledgeCardsDesk/VBoxContainer/FirstRowHBoxContainer/TopLeftKnowledgeCardComponent, 
	$KnowledgeCardsDesk/VBoxContainer/FirstRowHBoxContainer/TopMiddleKnowledgeCardComponent, 
	$KnowledgeCardsDesk/VBoxContainer/FirstRowHBoxContainer/TopRightKnowledgeCardComponent, 
	$KnowledgeCardsDesk/VBoxContainer/SecondRowHBoxContainer/BottomLeftKnowledgeCardComponent, 
	$KnowledgeCardsDesk/VBoxContainer/SecondRowHBoxContainer/BottomRightKnowledgeCardComponent
]

@onready var knowledge_cards_desk_close_button: Button = $KnowledgeCardsDesk/KnowledgeCardsDeskCloseButton


func _ready():
	GameManager.knowledge_card_changed.connect(_update_knowledge_cards)
	GameManager.toggle_knowledge_card_desk_requested.connect(_toggle_knowledge_cards_desk_visibility)
	GameManager.set_knowledge_card_desk_close_button_disabled_requested.connect(_set_knowledge_card_desk_close_button_disabled)
	GameManager.set_ui_button_disabled_requested.connect(_on_set_ui_button_disabled_requested)
	
	_populate_knowledge_card_components()
	_set_utility_disabled(true)

func _populate_knowledge_card_components():
	var player_knowledge_cards: Array[KnowledgeCardResource] = GameManager.get_local_player_knowledge_cards()
	for index in range(knowledge_card_components.size()):
		var current_knowledge_card_component: KnowledgeCardComponent = knowledge_card_components[index]
		if index < player_knowledge_cards.size():
			current_knowledge_card_component.set_topic(player_knowledge_cards[index].description)
			current_knowledge_card_component.show()
		else:
			current_knowledge_card_component.hide()

func _update_knowledge_cards():
	_populate_knowledge_card_components()

func _set_utility_disabled(is_disabled: bool):
	# Only close if we need to disable, if we enable do not show it
	if is_disabled:
		_toggle_knowledge_cards_desk_visibility(not is_disabled)
	open_knowledge_cards_desk_button.disabled = is_disabled

func _set_knowledge_card_desk_close_button_disabled(is_disabled: bool):
	knowledge_cards_desk_close_button.disabled = is_disabled

func _toggle_knowledge_cards_desk_visibility(is_next_visible: bool):
	knowledge_cards_desk.visible = is_next_visible
	knowledge_cards_desk_close_button.visible = is_next_visible
	_set_knowledge_card_desk_close_button_disabled(not is_next_visible)
	
	open_knowledge_cards_desk_button.visible = not is_next_visible

func _on_close_button_pressed() -> void:
	_toggle_knowledge_cards_desk_visibility(false) # this is important here
	GameManager.on_knowledge_card_desk_closed()

func _on_open_knowledge_cards_desk_button_pressed() -> void:
	_toggle_knowledge_cards_desk_visibility(true)

func _on_set_ui_button_disabled_requested(is_disabled: bool):
	_set_utility_disabled(is_disabled)
