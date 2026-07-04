class_name NotificationUtility
extends Control

@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer

func _ready() -> void:
	self.hide()
	
	GameManager.push_notification_requested.connect(push_notification)

func push_notification(message: String, display_time: float = 3.0) -> void:
	var log_label = Label.new()
	log_label.text = message
	
	# Add an outline so it's readable against any background
	log_label.add_theme_constant_override("outline_size", 4)
	log_label.add_theme_color_override("font_outline_color", Color.BLACK)
	
	v_box_container.add_child(log_label)
	
	var tween = create_tween()
	# Wait for the display time (e.g., 3 seconds)
	tween.tween_interval(display_time)
	# Fade the text opacity (modulate:a) from 1.0 to 0.0 over 0.5 seconds
	tween.tween_property(log_label, "modulate:a", 0.0, 0.5)
	# Once the fade is finished, delete the label from the game
	tween.tween_callback(log_label.queue_free)

func _on_v_box_container_child_entered_tree(_node: Node) -> void:
	if v_box_container.get_child_count() == 1:
		self.show()

func _on_v_box_container_child_exiting_tree(_node: Node) -> void:
	if v_box_container.get_child_count() == 1:
		self.hide()
