extends Node

const DOG_SCENE: PackedScene = preload("res://scenes/dog.tscn")
const FOOD_BOWL_SCENE: PackedScene = preload("res://scenes/food_bowl.tscn")
const TOY_SCENE: PackedScene = preload("res://scenes/toy.tscn")
const WATER_BOWL_SCENE: PackedScene = preload("res://scenes/water_bowl.tscn")

const GAME_AREA_WIDTH = 1280
const ITEM_Y_POSITION = 657

const DOG_POS: Vector2 = Vector2(640, 275)
const FOOD_BOWL_POS: Vector2 = Vector2(640, ITEM_Y_POSITION) 
const TOY_POS: Vector2 = Vector2(821, ITEM_Y_POSITION)
const WATER_BOWL_POS: Vector2 = Vector2(460, ITEM_Y_POSITION)

const SPRITE_SCALE: Vector2 = Vector2(0.75, 0.75)

const TEST_ICON = preload("res://icon.svg")
const MAX_PATIENCE_COUNT: int = 3

@onready var level_timer = $LevelTimer

@onready var pause_menu = $PauseMenu
@onready var item_hotbar = $ItemHotbar
@onready var background_music = $BackgroundMusic

var current_patience_count: int

# Game area will be just above position of items
var game_size: Vector2 = Vector2(GAME_AREA_WIDTH, ITEM_Y_POSITION - 70)

var food_bowl_scene_instance
var toy_scene_instance
var water_bowl_scene_instance

func _ready() -> void:
	gameGlobals.can_drag_item = true
	
	level_timer.level_finished.connect(level_finished)
	
	current_patience_count = MAX_PATIENCE_COUNT
	
	create_borders()
	spawn_items()
	spawn_animals()

func _physics_process(_delta) -> void:
	pass

func spawn_items() -> void:
	food_bowl_scene_instance = FOOD_BOWL_SCENE.instantiate()
	toy_scene_instance = TOY_SCENE.instantiate()
	water_bowl_scene_instance = WATER_BOWL_SCENE.instantiate()
	
	add_child(food_bowl_scene_instance)
	add_child(toy_scene_instance)
	add_child(water_bowl_scene_instance)

func spawn_animals() -> void:
	# Animal positions need to be randomized in a given area
	var dog_instance = DOG_SCENE.instantiate()
	dog_instance.position = DOG_POS
	
	dog_instance.patience_lost.connect(update_patience_count)
	
	add_child(dog_instance)
	
	#for i in range (2):
		#var dog_instance = DOG_SCENE.instantiate()
		#dog_instance.position = Vector2(randf() * 1024, randf() * 768)
		#dog_instance.patience_lost.connect(update_patience_count)
		#add_child(dog_instance)

# Triggers when our animal instance emits patience_lost signal
func update_patience_count() -> void:
	# This does not work with multiple animals. Play the game with multiple
	# animals enabled and then look at the debug window, it is counting the
	# patience down multiple times for multiple animals if they are the same
	# animal.
	#
	# How do we differentiate between the animal?
	current_patience_count = current_patience_count - 1
	
	print("Patience count: ", current_patience_count)
	
	if current_patience_count == 0:
		game_finished()

func game_finished() -> void:
	# For debugging purposes only. We would ideally handle this bool vars
	# and if game is truly over then we would switch to our UI to show game
	# over instead of just quitting the game.
	gameGlobals.is_game_finished = true
	print("Game Over")

# Triggers when our timer emits level_finished signal
func level_finished() -> void:
	gameGlobals.current_level = gameGlobals.current_level + 1
	
	print("Current level: ", gameGlobals.current_level)
	
	if gameGlobals.current_level >= (gameGlobals.MAX_LEVEL + 1):
		game_finished()

func create_borders():
	var border_thickness = 10  # Thickness of the border
	
	# Create top border
	var top_border = create_static_body(Vector2(game_size.x / 2, -border_thickness / 2), game_size.x, border_thickness)
	
	# Create bottom border
	var bottom_border = create_static_body(Vector2(game_size.x / 2, game_size.y + border_thickness / 2), game_size.x, border_thickness)
	
	# Create left border
	var left_border = create_static_body(Vector2(-border_thickness / 2, game_size.y / 2), border_thickness, game_size.y)
	
	# Create right border
	var right_border = create_static_body(Vector2(game_size.x + border_thickness / 2, game_size.y / 2), border_thickness, game_size.y)
	
	add_child(top_border)
	add_child(bottom_border)
	add_child(left_border)
	add_child(right_border)

# Function to create a static body with a rectangle shape
func create_static_body(position: Vector2, width: float, height: float) -> StaticBody2D:
	var static_body = StaticBody2D.new()
	static_body.position = position
	
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(width / 2, height / 2)
	collision_shape.shape = shape
	static_body.add_child(collision_shape)
	
	return static_body
