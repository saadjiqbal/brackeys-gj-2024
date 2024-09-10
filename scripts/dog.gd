extends CharacterBody2D

# Constants
const MAX_PATIENCE = 100.0
const MIN_PATIENCE = 0.0

# Properties
@export var patience_reduction_rate = 10 # Amount of patience lost per second
@export var speed: float = 2             # Movement speed
@export var min_interval: float = 5.0    # Min interval for random status timer
@export var max_interval: float = 15.0   # Max interval for random status timer
var patience: float = 100.0              # A patience meter starting at 100
var status_time_accumulator: float = 0.0 # Accumulates time for triggering status
var status_interval: float = 0.0         # Interval to wait for triggering status

# Possible variables to use in future
var hunger: float = 0.0                  # Hunger level
var thirst: float = 0.0                  # Thirst level
var playfulness: float = 0.0             # Playfulness level


var drink_water: bool = false
var eat_food: bool = false
var cursor_on_animal: bool = false

# Statuses
var statuses: Array = ["hunger", "thirst", "play"]  # Possible statuses

# RNG to determine which status is affecting the animal
var current_status: String = ""

# References to the UI elements
@onready var progress_bar = $CollisionShape2D/ProgressBar
@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene
func _ready():
	# Initialize the patience meter and status randomly
	progress_bar.value = MAX_PATIENCE
	reset_status_timer()

func _physics_process(delta):
	if Input.is_action_just_pressed("action") and cursor_on_animal:
		show_affection()

	# Accumulate timer and trigger status if not already set, based on random interval
	status_time_accumulator += delta
	if status_time_accumulator >= status_interval:
		if current_status == "":
			current_status = get_random_status()
			print(current_status)

	if drink_water:
		thirsty(current_status, delta)
	
	if eat_food:
		hungry(current_status, delta)

	# Decrease patience over time if status is set
	if current_status != "":
		patience -= delta * patience_reduction_rate  # Decrease patience by a rate
	check_patience()

	var direction = Vector2.ZERO

	# Handle input for movement. TODO: Generate this automatically
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	# Normalize direction to ensure consistent speed
	if direction.length() > 0:
		direction = direction.normalized()

	# Move the Dog
	move_and_collide(direction * speed)

	# Update animation based on direction
	update_animation(direction)

func update_animation(direction: Vector2):
	if direction.x > 0:
		# Moving right
		animated_sprite.play("walk")
	elif direction.x < 0:
		# Moving left
		animated_sprite.play("walk")
	elif direction.y > 0:
		# Moving down
		animated_sprite.play("walk")
	elif direction.y < 0:
		# Moving up
		animated_sprite.play("walk")

func reset_status_timer():
	status_time_accumulator = 0
	status_interval = randf_range(min_interval, max_interval)

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
	patience = MAX_PATIENCE
	print("Patience ran out! The animal is unhappy.")

# Implement logic for animal being thirsty
func thirsty(status: String, delta: float):
	if status == "thirst":
		print("Drinking water")
		current_status = ""
		reset_status_timer()
	elif status != "":
		patience -= patience_reduction_rate * delta

# Implement logic for animal being hungry
func hungry(status: String, delta: float):
	if status == "hunger":
		print("Eating food")
		current_status = ""
		reset_status_timer()
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
