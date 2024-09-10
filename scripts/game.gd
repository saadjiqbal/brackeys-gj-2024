extends Node2D

const DOG = preload("res://scenes/dog.tscn")
const FOOD_BOWL = preload("res://scenes/food_bowl.tscn")
const WATER_BOWL_SCENE = preload("res://scenes/water_bowl.tscn")

func _ready() -> void:
	gameGlobals.can_drag_item = true
	var dog_scene_instance = DOG.instantiate()
	var food_bowl_scene_instance = FOOD_BOWL.instantiate()
	var water_bowl_scene_instance = WATER_BOWL_SCENE.instantiate()
	
	add_child(dog_scene_instance)
	add_child(food_bowl_scene_instance)
	add_child(water_bowl_scene_instance)

func _physics_process(_delta) -> void:
	pass
