@tool
class_name StructureResource
extends Resource

@export var name: String
@export var texture: Texture2D

@export var is_building_limited: bool = false:
	set(value):
		is_building_limited = value
		# Forces the Inspector to immediately refresh when you click the checkbox
		notify_property_list_changed()

@export var limit_amount: int = 1 

func _validate_property(property: Dictionary) -> void:
	# Check if the Inspector is currently trying to draw the "limit_amount" variable
	if property.name == "limit_amount":
		if not is_building_limited:
			# Hide it from the editor, but keep PROPERTY_USAGE_STORAGE so it 
			# doesn't delete your saved data if you accidentally uncheck the box
			property.usage = PROPERTY_USAGE_STORAGE
