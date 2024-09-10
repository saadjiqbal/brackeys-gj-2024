extends Node2D

const DOG_SCENE: PackedScene = preload("res://scenes/dog.tscn")
const FOOD_BOWL_SCENE: PackedScene = preload("res://scenes/food_bowl.tscn")
const TOY_SCENE: PackedScene = preload("res://scenes/toy.tscn")
const WATER_BOWL_SCENE: PackedScene = preload("res://scenes/water_bowl.tscn")

const DOG_POS: Vector2 = Vector2(640, 275)
const FOOD_BOWL_POS: Vector2 = Vector2(150, 100) 
const TOY_POS: Vector2 = Vector2(450, 100)
const WATER_BOWL_POS: Vector2 = Vector2(300, 100)

var game_size: Vector2 = Vector2(1024, 768) # TODO: Confirm this

func _ready() -> void:
	gameGlobals.can_drag_item = true
	
	spawn_items()
	spawn_animals()

func _physics_process(_delta) -> void:
	pass

func spawn_items() -> void:
	var food_bowl_instance = FOOD_BOWL_SCENE.instantiate()
	var toy_instance = TOY_SCENE.instantiate()
	var water_bowl_instance = WATER_BOWL_SCENE.instantiate()
	
	food_bowl_instance.position = FOOD_BOWL_POS
	toy_instance.position = TOY_POS
	water_bowl_instance.position = WATER_BOWL_POS
	
	add_child(food_bowl_instance)
	add_child(toy_instance)
	add_child(water_bowl_instance)

func spawn_animals() -> void:
	# Animal positions need to be randomized in a given area
	var dog_instance = DOG_SCENE.instantiate()
	
	dog_instance.position = DOG_POS
	
	add_child(dog_instance)
