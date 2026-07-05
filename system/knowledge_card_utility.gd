class_name KnowledgeCardUtility
extends Control

var game_resource_indexes: Dictionary[String, int] = {}
@onready var knowledge_card_components: Array[KnowledgeCardComponent] = [
	$VBoxContainer/FirstRowHBoxContainer/TopLeftKnowledgeCardComponent, 
	$VBoxContainer/FirstRowHBoxContainer/TopMiddleKnowledgeCardComponent, 
	$VBoxContainer/FirstRowHBoxContainer/TopRightKnowledgeCardComponent, 
	$VBoxContainer/SecondRowHBoxContainer/BottomLeftKnowledgeCardComponent, 
	$VBoxContainer/SecondRowHBoxContainer/BottomRightKnowledgeCardComponent
]

func _ready():
	GameManager.knowledge_card_changed.connect(_update_knowledge_cards)
	_populate_knowledge_card_components()
	self.hide()

func _populate_knowledge_card_components():
	var player_knowledge_cards: Array[KnowledgeCardResource] = GameManager.get_local_player_knowledge_cards()
	for index in range(knowledge_card_components.size()):
		var current_knowledge_card_component: KnowledgeCardComponent = knowledge_card_components[index]
		if index < player_knowledge_cards.size():
			current_knowledge_card_component.set_topic(player_knowledge_cards[index].description)
			current_knowledge_card_component.show()
		else:
			current_knowledge_card_component.hide()

func _update_knowledge_cards(_game_resource: GameResource, _new_value: float):
	_populate_knowledge_card_components()
