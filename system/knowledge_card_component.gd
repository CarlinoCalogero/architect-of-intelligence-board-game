class_name KnowledgeCardComponent
extends TextureRect

@onready var label: Label = $CenterContainer/Label

var knowledge_card_topic: String = ""

func set_topic(new_topic: String):
	label.text = new_topic
