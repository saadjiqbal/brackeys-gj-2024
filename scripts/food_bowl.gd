extends Node2D

var area_entered : bool = false
var draggable : bool = false
var offset : Vector2

func _physics_process(delta):
	if draggable:
		if Input.is_action_just_pressed("action"):
			offset = get_global_mouse_position() - self.position
			
		if Input.is_action_pressed("action"):
			self.position = get_global_mouse_position() - offset

func _on_area_2d_mouse_entered():
	draggable = true
	self.scale = Vector2(10.5, 10.5)

func _on_area_2d_mouse_exited():
	draggable = false
	self.scale = Vector2(10, 10)
