class_name Structure
extends Node2D

@export var texture: Texture2D:
	set(new_texture):
		texture = new_texture
		# Only try to update the sprite if the node has fully entered the tree
		if is_node_ready():
			_on_texture_changed()

@onready var structure_sprite_2d: Sprite2D = $StructureSprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SCALE_PERCENTAGE: float = 0.8

func _on_texture_changed() -> void:
	print("miao")
	structure_sprite_2d.texture = texture
	
	if texture != null:
		var target_size = texture.get_size()
		
		# Fallback size just in case the animation isn't set up yet
		var original_size = Vector2(32.0, 32.0)
		
		if animated_sprite_2d.sprite_frames != null:
			var current_anim = animated_sprite_2d.animation
			
			if animated_sprite_2d.sprite_frames.get_frame_count(current_anim) > 0:
				var frame_texture = animated_sprite_2d.sprite_frames.get_frame_texture(current_anim, 0)
				
				if frame_texture != null:
					original_size = frame_texture.get_size()
					print("target size: [", target_size, "], original size: [", original_size, "]")
		animated_sprite_2d.scale = (target_size / original_size) * SCALE_PERCENTAGE
