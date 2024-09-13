extends Node

const DOG_SCENE: PackedScene = preload("res://scenes/dog.tscn")
const FOOD_BOWL_SCENE: PackedScene = preload("res://scenes/food_bowl.tscn")
const TOY_SCENE: PackedScene = preload("res://scenes/toy.tscn")
const WATER_BOWL_SCENE: PackedScene = preload("res://scenes/water_bowl.tscn")

const DOG_POS: Vector2 = Vector2(640, 275)
const FOOD_BOWL_POS: Vector2 = Vector2(150, 100) 
const TOY_POS: Vector2 = Vector2(450, 100)
const WATER_BOWL_POS: Vector2 = Vector2(300, 100)
const TEST_ICON = preload("res://icon.svg")
const MAX_PATIENCE_COUNT: int = 3

@onready var level_timer = $LevelTimer
@onready var background_music = $BackgroundMusic
@onready var pause_menu = $PauseMenu
@onready var item_hotbar = $ItemHotbar

var current_patience_count: int
var game_size: Vector2 = Vector2(1280, 720)
var is_game_over: bool
var is_game_paused: bool

var is_food_bowl_hovered: bool = false
var is_toy_hovered: bool = false
var is_water_bowl_hovered: bool = false

var food_bowl_sprite: Sprite2D
var food_bowl_sprite_offset: Vector2

func _ready() -> void:
	gameGlobals.can_drag_item = true
	
	level_timer.level_finished.connect(level_finished)
	
	item_hotbar.food_bowl_hovered.connect(on_food_bowl_hover)
	item_hotbar.toy_hovered.connect(on_toy_hover)
	item_hotbar.water_bowl_hovered.connect(on_water_bowl_hover)
	
	background_music.play()
	
	current_patience_count = MAX_PATIENCE_COUNT
	
	food_bowl_sprite = Sprite2D.new()
	
	is_game_over = false
	is_game_paused = false
	
	create_borders()
	#spawn_items()
	spawn_animals()

func _physics_process(_delta) -> void:
	if Input.is_action_just_pressed("action") and is_food_bowl_hovered:
		food_bowl_sprite = Sprite2D.new()
		food_bowl_sprite.texture = load("res://icon.svg")
		food_bowl_sprite.position = Vector2(640, 643)
		
		add_child(food_bowl_sprite)
		
		food_bowl_sprite_offset = get_viewport().get_mouse_position() - food_bowl_sprite.position
		
		gameGlobals.can_drag_item = false

	if Input.is_action_pressed("action") and is_food_bowl_hovered:
		food_bowl_sprite.position = get_viewport().get_mouse_position() - food_bowl_sprite_offset
	elif Input.is_action_just_released("action"):
		gameGlobals.can_drag_item = true

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

func on_food_bowl_hover() -> void:
	if gameGlobals.can_drag_item:
		is_food_bowl_hovered = true

func on_toy_hover() -> void:
	is_toy_hovered = true

func on_water_bowl_hover() -> void:
	is_water_bowl_hovered = true
