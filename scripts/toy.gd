extends Node2D

const SCALE_ON_HOVER : Vector2 = Vector2(8.5, 8.5) 
const DEFAULT_POSITION: Vector2 = Vector2(821, 657)

@onready var toy_timer = %ToyTimer
@onready var sprite_2d = $Sprite2D

var draggable : bool = false
var sprite_offset : Vector2
var scale_on_load : Vector2

func _ready() -> void:
	scale_on_load = self.scale

func _physics_process(_delta) -> void:
	if draggable:
		if Input.is_action_just_pressed("action"):
			sprite_offset = get_global_mouse_position() - self.position
			gameGlobals.can_drag_item = false
			
		if Input.is_action_pressed("action"):
			self.position = get_global_mouse_position() - sprite_offset
		elif Input.is_action_just_released("action"):
			gameGlobals.can_drag_item = true
			toy_timer.start()

func reset_position() -> void:
	self.position = DEFAULT_POSITION

func _on_toy_area_mouse_entered():
	if gameGlobals.can_drag_item:
		draggable = true
		sprite_2d.texture = load("res://assets/items/toy2_highlighted.png")
		self.scale = SCALE_ON_HOVER

func _on_toy_area_mouse_exited():
	if gameGlobals.can_drag_item:
		draggable = false
		sprite_2d.texture = load("res://assets/items/toy2.png")
		self.scale = scale_on_load

func _on_toy_timer_timeout():
	reset_position()
