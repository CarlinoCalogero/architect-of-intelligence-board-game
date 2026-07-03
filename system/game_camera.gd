class_name GameCamera
extends Camera2D

@onready var top_left: Marker2D = $Limits/TopLeft
@onready var bottom_right: Marker2D = $Limits/BottomRight

# MIN means furthest out, MAX means closest in.
@export var min_zoom: float = 1.0 
@export var max_zoom: float = 20.0
@export var zoom_step: float = 1.00

var _is_panning: bool = false

func _ready():
	# Detach the markers from the camera so they stay locked in place
	top_left.set_as_top_level(true)
	bottom_right.set_as_top_level(true)
	
	# Use global_position to grab their exact world coordinates
	limit_top = int(top_left.global_position.y)
	limit_left = int(top_left.global_position.x)
	limit_bottom = int(bottom_right.global_position.y)
	limit_right = int(bottom_right.global_position.x)

func _input(event: InputEvent) -> void:
	# --- ZOOMING ---
	if event.is_action_pressed("scroll_down"): # Zoom Out
		var new_zoom = clamp(zoom.x - zoom_step, min_zoom, max_zoom)
		_update_camera_zoom(Vector2(new_zoom, new_zoom))
		
	elif event.is_action_pressed("scroll_up"): # Zoom In
		var new_zoom = clamp(zoom.x + zoom_step, min_zoom, max_zoom)
		_update_camera_zoom(Vector2(new_zoom, new_zoom))
	
	# --- PANNING ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.is_pressed():
				_is_panning = true
			else:
				_is_panning = false
				
	if event is InputEventMouseMotion and _is_panning:
		# Shift the camera in the opposite direction of the mouse movement.
		# We divide by 'zoom' so the ground sticks perfectly to the mouse pointer.
		global_position -= event.relative / zoom
		_clamp_camera_position()

func _update_camera_zoom(new_zoom_value: Vector2) -> void:
	var mouse_pos_before = get_global_mouse_position()
	zoom = new_zoom_value
	var mouse_pos_after = get_global_mouse_position()
	global_position += (mouse_pos_before - mouse_pos_after)
	
	_clamp_camera_position()

func _clamp_camera_position() -> void:
	var viewport_size = get_viewport_rect().size / zoom
	var half_width = viewport_size.x / 2.0
	var half_height = viewport_size.y / 2.0
	
	# Replace Marker2D references with Godot's built-in limit variables
	var min_x = limit_left + half_width
	var max_x = limit_right - half_width
	var min_y = limit_top + half_height
	var max_y = limit_bottom - half_height

	if min_x > max_x:
		global_position.x = (limit_left + limit_right) / 2.0
	else:
		global_position.x = clamp(global_position.x, min_x, max_x)
		
	if min_y > max_y:
		global_position.y = (limit_top + limit_bottom) / 2.0
	else:
		global_position.y = clamp(global_position.y, min_y, max_y)
