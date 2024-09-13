extends CharacterBody2D

signal patience_lost

# Constants
const MAX_PATIENCE = 100.0
const MIN_PATIENCE = 0.0
const MIN_MOVEMENT_DISTANCE = 20.0
const STATUS_ICON_SCENE: PackedScene = preload("res://scenes/status_icon.tscn")

# Properties
@export var patience_reduction_rate = 10 # Amount of patience lost per second
@export var speed: float = 2             # Movement speed
@export var min_interval: float = 5.0    # Min interval for random status timer
@export var max_interval: float = 15.0   # Max interval for random status timer

var patience: float = 100.0              # A patience meter starting at 100
var status_time_accumulator: float = 0.0 # Accumulates time for triggering status
var status_interval: float = 0.0         # Interval to wait for triggering status
var move_time_accumulator: float = 0.0   # Accumulates time for triggering movement
var move_interval: float = 0.0           # Interval to wait for triggering movement
var patience_loss_count: int = 0

var is_moving: bool = false
var target_position = Vector2()  # Target position

# Possible variables to use in future
var hunger: float = 0.0                  # Hunger level
var thirst: float = 0.0                  # Thirst level
var playfulness: float = 0.0             # Playfulness level
var drink_water: bool = false            
var eat_food: bool = false               
var cursor_on_animal: bool = false       

# Statuses
var statuses: Array = [gameGlobals.HUNGER_STATUS, gameGlobals.THIRST_STATUS, gameGlobals.PLAY_STATUS, gameGlobals.AFFECTION_STATUS]  # Possible statuses
var status_icon : Node2D
var current_status: String = ""
var game_area: Vector2

# References to the UI elements
@onready var progress_bar = $ProgressBar
@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene
func _ready():
	# Initialize the patience meter and status randomly
	progress_bar.value = MAX_PATIENCE
	var game_scene = get_parent()
	game_area = game_scene.game_size
	init_status_icon()
	reset_status()
	reset_movement_timer()

func _physics_process(delta):
	# Accumulate timer and trigger status if not already set, based on random interval
	status_time_accumulator += delta
	if status_time_accumulator >= status_interval:
		if current_status == "":
			current_status = get_random_status()
			status_icon.show_icon(current_status)
			print(current_status)

	if not is_moving:
		move_time_accumulator += delta
		if move_time_accumulator >= move_interval:
			set_random_position()
			is_moving = true

	if drink_water:
		thirsty(current_status, delta)
	
	if eat_food:
		hungry(current_status, delta)

	# Left click will show affection or move the dog
	# TODO: Fix mouse click not working
	#if Input.is_action_just_pressed("action") and cursor_on_animal:
	if Input.is_action_just_pressed("action"):
		if not drink_water and not eat_food:
			if gameGlobals.is_affection_cursor_selected:
				show_affection()
			else:
				target_position = get_global_mouse_position()
				is_moving = true

	# Decrease patience over time if status is set
	if current_status != "":
		patience -= delta * patience_reduction_rate  # Decrease patience by a rate
	check_patience()

	# Update animation based on direction
	var direction = (target_position - position).normalized()
	if is_moving:
		move_to_target(direction)
	update_animation(is_moving, direction)

# Initialise status icon as invisible and to the right of progress bar
func init_status_icon():
	status_icon = STATUS_ICON_SCENE.instantiate()
	status_icon.position = Vector2(12, - 3)
	add_child(status_icon)
	status_icon.hide_icon()

func move_to_target(direction: Vector2):
	velocity = direction * speed
	move_and_collide(velocity)

	# Check if the dog is close enough to the target
	if position.distance_to(target_position) < 5:
		# Stop moving and reset timer
		is_moving = false
		reset_movement_timer()
		print("Reached target, waiting for ", move_interval, " seconds")

func set_random_position():
	while true:
		target_position = Vector2(randf_range(0, game_area.x), randf_range(0, game_area.y))
		if position.distance_to(target_position) >= MIN_MOVEMENT_DISTANCE:
			break

func update_animation(is_moving: bool, direction: Vector2):
	if not is_moving:
		animated_sprite.play("idle")
	elif direction.x > 0:
		# Moving right
		animated_sprite.play("walk")
		animated_sprite.flip_h = false
	elif direction.x < 0:
		# Moving left
		animated_sprite.play("walk")
		animated_sprite.flip_h = true

func reset_status():
	current_status = ""
	status_time_accumulator = 0
	status_interval = randf_range(min_interval, max_interval)
	status_icon.hide_icon()

func reset_movement_timer():
	move_time_accumulator = 0
	move_interval = randf_range(min_interval, max_interval)

# Function to handle random status selection
func get_random_status() -> String:
	var rand_index = randi() % statuses.size()
	return statuses[rand_index]

# Function to check and respond to patience level
func check_patience():
	progress_bar.value = patience
	if patience <= MIN_PATIENCE:
		handle_patience_loss()

func handle_patience_loss():
	# Reset and print message for now
	patience_loss_count += 1
	if patience_loss_count == 1:
		progress_bar.update_fill_colour(Color.ORANGE)
	else:
		progress_bar.update_fill_colour(Color.RED)
	patience = MAX_PATIENCE
	patience_lost.emit()
	print("Patience ran out! The animal is unhappy.")

# Implement logic for animal being thirsty
func thirsty(status: String, delta: float):
	if status == gameGlobals.THIRST_STATUS:
		print("Drinking water")
		reset_status()
	elif status != "":
		patience -= patience_reduction_rate * delta

# Implement logic for animal being hungry
func hungry(status: String, delta: float):
	if status == gameGlobals.HUNGER_STATUS:
		print("Eating food")
		reset_status()
	elif status != "":
		patience -= patience_reduction_rate * delta

func show_affection() -> void:
	print("Showing affection")

# Check what has entered our Area2D node
func _on_animal_action_area_area_entered(area):
	if area.name == "WaterBowlArea":
		drink_water = true
	elif area.name == "FoodBowlArea":
		eat_food = true
	elif area.name == "AnimalActionArea":
		# TODO: Stop moving and start throwing some hands
		print("Colliding with animal")

# Check what has exited our Area2D node
func _on_animal_action_area_area_exited(area):
	if area.name == "WaterBowlArea":
		print("Done drinking water")
		drink_water = false
	elif area.name == "FoodBowlArea":
		print("Done eating food")
		eat_food = false

# Check if mouse is inside our Area2D node
func _on_animal_action_area_mouse_entered():
	cursor_on_animal = true

# Check if mouse has exited our Area2D node
func _on_animal_action_area_mouse_exited():
	cursor_on_animal = false
