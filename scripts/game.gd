extends Node

const DOG_SCENE: PackedScene = preload("res://scenes/dog.tscn")
const FOOD_BOWL_SCENE: PackedScene = preload("res://scenes/food_bowl.tscn")
const TOY_SCENE: PackedScene = preload("res://scenes/toy.tscn")
const WATER_BOWL_SCENE: PackedScene = preload("res://scenes/water_bowl.tscn")

const DOG_POS: Vector2 = Vector2(640, 275)
const FOOD_BOWL_POS: Vector2 = Vector2(150, 100) 
const TOY_POS: Vector2 = Vector2(450, 100)
const WATER_BOWL_POS: Vector2 = Vector2(300, 100)

const MAX_PATIENCE_COUNT: int = 3

@onready var level_timer = $LevelTimer
@onready var background_music = $BackgroundMusic
@onready var pause_menu = $PauseMenu

var current_patience_count: int
var game_size: Vector2 = Vector2(1024, 768) # TODO: Confirm this]
var is_game_over: bool
var is_game_paused: bool


var hotbar_inventory: Array = []

func _ready() -> void:
	gameGlobals.can_drag_item = true
	
	level_timer.level_finished.connect(level_finished)
	
	background_music.play()
	
	current_patience_count = MAX_PATIENCE_COUNT
	
	is_game_over = false
	is_game_paused = false
	
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
