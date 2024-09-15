extends Node2D

const SCALE_ON_HOVER : Vector2 = Vector2(10.5, 10.5)
const DEFAULT_POSITION: Vector2 = Vector2(640, 657)

var draggable: bool = false
var sprite_offset : Vector2
var scale_on_load : Vector2

@onready var food_bowl_timer = %FoodBowlTimer
@onready var sprite_2d = $Sprite2D

func _ready() -> void:
	scale_on_load = self.scale

func _physics_process(_delta) -> void:
	if not gameGlobals.game_over or not gameGlobals.game_win:
		if draggable:
			if Input.is_action_just_pressed("action"):
				sprite_offset = get_global_mouse_position() - self.position
				gameGlobals.can_drag_item = false
				
			if Input.is_action_pressed("action"):
				self.position = get_global_mouse_position() - sprite_offset
			elif Input.is_action_just_released("action"):
				gameGlobals.can_drag_item = true
				food_bowl_timer.start()
				
		if Input.is_action_just_pressed("spacebar"):
			reset_position()

func reset_position() -> void:
	self.position = DEFAULT_POSITION

func _on_food_bowl_area_mouse_entered():
	if gameGlobals.can_drag_item:
		draggable = true
		gameGlobals.is_food_bowl_draggable = true
		sprite_2d.texture = load("res://assets/items/foodbowl_highlighted.png")
		self.scale = SCALE_ON_HOVER


func _on_food_bowl_area_mouse_exited():
	if gameGlobals.can_drag_item:
		draggable = false
		gameGlobals.is_food_bowl_draggable = false
		sprite_2d.texture = load("res://assets/items/foodbowl.png")
		self.scale = scale_on_load

func _on_food_bowl_timer_timeout():
	reset_position()
