extends Node

const DOG_SCENE: PackedScene = preload("res://scenes/dog.tscn")
const FOOD_BOWL_SCENE: PackedScene = preload("res://scenes/food_bowl.tscn")
const TOY_SCENE: PackedScene = preload("res://scenes/toy.tscn")
const WATER_BOWL_SCENE: PackedScene = preload("res://scenes/water_bowl.tscn")

const GAME_AREA_WIDTH = 1280
const ITEM_Y_POSITION = 657

const DOG_POS_LEVEL_1: Vector2 = Vector2(640, 275)
const DOG1_POS_LEVEL_2: Vector2 = Vector2(240, 275)
const DOG2_POS_LEVEL_2: Vector2 = Vector2(1000, 275)
const DOG1_POS_LEVEL_3: Vector2 = Vector2(240, 400)
const DOG2_POS_LEVEL_3: Vector2 = Vector2(1000, 400)
const DOG3_POS_LEVEL_3: Vector2 = Vector2(640, 100)

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

@onready var game_over_sfx = $GameOverSFX
@onready var game_win_sfx = $GameWinSFX

@onready var level_1 = $"Level 1"
@onready var level_2 = $"Level 2"
@onready var level_3 = $"Level 3"

var current_patience_count: int

# Game area will be just above position of items
var game_size: Vector2 = Vector2(GAME_AREA_WIDTH, ITEM_Y_POSITION - 70)

var food_bowl_scene_instance
var toy_scene_instance
var water_bowl_scene_instance

func _ready() -> void:
	gameGlobals.can_drag_item = true
	gameGlobals.game_over = false
	gameGlobals.game_win = false
	gameGlobals.current_level = 1
	
	level_timer.level_finished.connect(level_finished)
	
	current_patience_count = MAX_PATIENCE_COUNT
	
	level_1.visible = true
	level_2.visible = false
	level_3.visible = false
	
	create_borders()
	spawn_items()
	instantiate_dog(DOG_POS_LEVEL_1)

func _physics_process(_delta) -> void:
	pass

# Reset item positions and delete dog instances
func reset_level():
	food_bowl_scene_instance.reset_position()
	toy_scene_instance.reset_position()
	water_bowl_scene_instance.reset_position()
	
	for child in get_children():
		if child is CharacterBody2D:
			child.queue_free()

# Initialise dog positions for a new level
func start_new_level(level_count: int):
	if level_count == 2:
		# Spawn 2 dogs
		instantiate_dog(DOG1_POS_LEVEL_2)
		instantiate_dog(DOG2_POS_LEVEL_2)
	elif level_count == 3:
		# Spawn 3 dogs
		instantiate_dog(DOG1_POS_LEVEL_3)
		instantiate_dog(DOG2_POS_LEVEL_3)
		instantiate_dog(DOG3_POS_LEVEL_3)

func spawn_items() -> void:
	food_bowl_scene_instance = FOOD_BOWL_SCENE.instantiate()
	toy_scene_instance = TOY_SCENE.instantiate()
	water_bowl_scene_instance = WATER_BOWL_SCENE.instantiate()
	
	add_child(food_bowl_scene_instance)
	add_child(toy_scene_instance)
	add_child(water_bowl_scene_instance)

func instantiate_dog(position: Vector2):
	var dog_instance = DOG_SCENE.instantiate()
	dog_instance.position = position
	dog_instance.patience_lost.connect(game_over)
	add_child(dog_instance)

func game_over() -> void:
	# Add logic to stop dog moving & stop music + play a game over sound effect / music
	gameGlobals.game_over = true
	gameGlobals.can_drag_item = false
	mainMusic._stop_music()
	game_over_sfx.play()
	
	print("Game Over")

func game_win() -> void:
	gameGlobals.game_win = true
	gameGlobals.can_drag_item = false
	mainMusic._stop_music()
	game_win_sfx.play()
	
	print("Game Win")

# Triggers when our timer emits level_finished signal
func level_finished() -> void:
	# pass 1, finished level 1, current_level = 1
	# pass 2, finished level 2, current_level = 2
	# pass 3, finished level 3, curren_level = 3
	print("Current level: ", gameGlobals.current_level)
	if gameGlobals.current_level >= gameGlobals.MAX_LEVEL:
		game_win()
	
	gameGlobals.current_level = gameGlobals.current_level + 1

	level_transition()
	reset_level()
	start_new_level(gameGlobals.current_level)

func level_transition()-> void:
	if gameGlobals.current_level == 2:
		level_1.visible = false
		level_2.visible = true
		level_3.visible = false
	elif gameGlobals.current_level == 3:
		level_1.visible = false
		level_2.visible = false
		level_3.visible = true

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
