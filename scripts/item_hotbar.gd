extends Control

signal food_bowl_hovered
signal toy_hovered
signal water_bowl_hovered

@onready var food_bowl = $MarginContainer/HotbarContainer/FoodBowl
@onready var toy = $MarginContainer/HotbarContainer/Toy
@onready var water_bowl = $MarginContainer/HotbarContainer/WaterBowl

var food_bowl_draggable: bool = false
var toy_draggable: bool = false
var water_bowl_draggable: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	print(food_bowl.get_global_position())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	check_hovered_item()

func check_hovered_item() -> void:
	if food_bowl.is_hovered():
		food_bowl_hovered.emit()
		
	if toy.is_hovered():
		toy_hovered.emit()

	if water_bowl.is_hovered():
		water_bowl_hovered.emit()
