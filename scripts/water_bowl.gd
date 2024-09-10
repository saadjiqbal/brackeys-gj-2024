extends Node2D

const SCALE_ON_HOVER : Vector2 = Vector2(10.5, 10.5) 

var draggable : bool = false
var sprite_offset : Vector2
var scale_on_load : Vector2

func _ready() -> void:
	scale_on_load = self.scale

func _physics_process(_delta) -> void:
	if draggable:
		if Input.is_action_just_pressed("action"):
			sprite_offset = get_global_mouse_position() - self.position
			
		if Input.is_action_pressed("action"):
			self.position = get_global_mouse_position() - sprite_offset

func _on_area_2d_mouse_entered():
	draggable = true
	self.scale = SCALE_ON_HOVER

func _on_area_2d_mouse_exited():
	draggable = false
	self.scale = scale_on_load
