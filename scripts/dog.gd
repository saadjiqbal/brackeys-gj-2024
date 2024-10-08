extends CharacterBody2D

signal patience_lost

# Constants
const MAX_PATIENCE_LOSS_COUNT = 3      # Max number of times dog's patience can reach 0
const MAX_PATIENCE = 100.0             # Max value of patience bar
const PATIENCE_INCREMENT = 20.0        # Amount patience bar increments when status is cured (one time increment per cure)
const MIN_PATIENCE = 0.0               # Min value of patience bar
const MIN_MOVEMENT_DISTANCE = 20.0     # Minimum distance to move when generating a new target position
const PATIENCE_LOSS_SPEED_FACTOR = 2   # Amount to increase speed by when patience lost 
const STATUS_ICON_SCENE: PackedScene = preload("res://scenes/status_icon.tscn")
const WRONG_ITEM_PATIENCE_REDUCE_FACTOR = 2 # Factor to multiply patience reduction by when wrong item is placed
const AFFECTION_PATIENCE_INCREMENT = 5 # Amount to increase patience when clicking on dog for affection

# Properties
@export var patience_reduction_rate = 10 # Amount of patience lost per second
@export var speed: float = 2             # Movement speed
@export var min_random_interval: float = 5.0    # Min interval for random status/movement timer
@export var max_random_interval: float = 10.0   # Max interval for random status/movement timer
@export var affection_timeout_s: float = 5.0    # Number of seconds that affection status lasts for 

var patience: float = 100.0              # A patience meter starting at 100
var status_time_accumulator: float = 0.0 # Accumulates time for triggering status
var status_interval: float = 0.0         # Interval to wait for triggering status
var move_time_accumulator: float = 0.0   # Accumulates time for triggering movement
var move_interval: float = 0.0           # Interval to wait for triggering movement
var patience_loss_count: int = 0
var patience_increment_rate = 20
var affection_timer_accumulator: float = 0.0

var is_attempting_cure_status: bool = false
var has_played_sfx_sound: bool = false
var is_moving: bool = false
var target_position = Vector2()  # Target position
var cursor_on_animal: bool = false       

# Statuses
var statuses: Array = [gameGlobals.HUNGER_STATUS, gameGlobals.THIRST_STATUS, gameGlobals.PLAY_STATUS, gameGlobals.AFFECTION_STATUS]  # Possible statuses
var status_icon : Node2D
var current_status: String = ""
var target_cure_status: String = ""
var game_area: Vector2

var drink_sfx = preload("res://assets/sfx/dog_drink.mp3")
var eat_sfx = preload("res://assets/sfx/dog_eat.mp3")
var play_sfx = preload("res://assets/sfx/bark3.mp3")
var status_popup_sfx = preload("res://assets/sfx/status_notification.mp3")
var whine_sfx = preload("res://assets/sfx/dog_whine.mp3")
var anger_sfx = preload("res://assets/sfx/dog_growl.mp3")

var item_status_dict = {
	"WaterBowlArea": gameGlobals.THIRST_STATUS,
	"FoodBowlArea": gameGlobals.HUNGER_STATUS,
	"ToyArea": gameGlobals.PLAY_STATUS
}

var status_curing_sfx_dict = {
	gameGlobals.THIRST_STATUS: drink_sfx,
	gameGlobals.HUNGER_STATUS: eat_sfx,
	gameGlobals.PLAY_STATUS: play_sfx,
	gameGlobals.AFFECTION_STATUS: play_sfx
}

var colliding_items = []

# References to the UI elements
@onready var progress_bar = $ProgressBar
@onready var animated_sprite = $AnimatedSprite2D
@onready var sfx_player = $AudioStreamPlayer2D

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
	accumulate_and_set_status(delta)

	# Accumulate timer and trigger movement, based on random interval
	accumulate_and_move(delta)

	check_is_status_cured(delta)

	# Left click will show affection
	if Input.is_action_just_pressed("action") and cursor_on_animal:
		if not is_attempting_cure_status:
			show_affection(delta)

	# Move animal on right click
	#if Input.is_action_just_pressed("right_click") and cursor_on_animal:
		#target_position = get_global_mouse_position()
		#is_moving = true

	# Decrease patience over time if status is set
	if current_status != "" and current_status != target_cure_status:
		patience -= delta * patience_reduction_rate # Decrease patience by a rate
		patience -= delta * patience_loss_count * patience_reduction_rate # Decrease further if already lost patience
	check_patience()

	# Stop moving when curing status or game is over
	if is_attempting_cure_status or patience_loss_count == MAX_PATIENCE_LOSS_COUNT:
		is_moving = false

	# Update animation based on direction
	var direction = (target_position - position).normalized()
	if is_moving:
		move_to_target(direction)
	update_animation(is_moving, direction)

func set_target_position(target_pos: Vector2):
	target_position = target_pos
	is_moving = true

func set_random_status():
	current_status = get_random_status()
	status_icon.show_icon(current_status)
	# Play special SFX for affection and reset timer
	if current_status == gameGlobals.AFFECTION_STATUS:
		sfx_player.stream = whine_sfx
		affection_timer_accumulator = 0
	else:
		sfx_player.stream = status_popup_sfx
	sfx_player.play()
	print(current_status)

func accumulate_and_set_status(delta: float):
	if current_status == "":
		status_time_accumulator += delta
		if status_time_accumulator >= status_interval:
			set_random_status()

	# Check affection timer, reset status if timed out
	if current_status == gameGlobals.AFFECTION_STATUS:
		affection_timer_accumulator += delta
		if affection_timer_accumulator >= affection_timeout_s:
			reset_status()


func accumulate_and_move(delta: float):
	if not is_moving and not is_attempting_cure_status:
		move_time_accumulator += delta
		if move_time_accumulator >= move_interval:
			set_random_position()
			is_moving = true

# Initialise status icon as invisible and to the right of progress bar
func init_status_icon():
	status_icon = STATUS_ICON_SCENE.instantiate()
	status_icon.position = Vector2(12, - 3)
	add_child(status_icon)
	status_icon.hide_icon()

func move_to_target(direction: Vector2):
	velocity = direction * (speed + (patience_loss_count * PATIENCE_LOSS_SPEED_FACTOR))
	var collision = move_and_collide(velocity)

	# Check if the dog is close enough to the target
	if position.distance_to(target_position) < 5 or collision:
		# Stop moving and reset timer
		is_moving = false
		reset_movement_timer()
		print("Reached target, waiting for ", move_interval, " seconds")

func set_random_position():
	while true:
		target_position = Vector2(randf_range(0, game_area.x), randf_range(0, game_area.y))
		print("Random position set to " + str(target_position))
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
	status_interval = randf_range(min_random_interval, max_random_interval)
	status_icon.hide_icon()

func reset_movement_timer():
	move_time_accumulator = 0
	move_interval = randf_range(min_random_interval, max_random_interval)

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
	if patience_loss_count < MAX_PATIENCE_LOSS_COUNT:
		print("Patience ran out! The animal is unhappy.")
		# Change progress bar colour and reset patience
		patience_loss_count += 1
		if patience_loss_count == 1:
			progress_bar.update_fill_colour(Color.ORANGE)
		else:
			progress_bar.update_fill_colour(Color.RED)

		if patience_loss_count == MAX_PATIENCE_LOSS_COUNT:
			patience_lost.emit()
			print("Patience ran out completely!")
		else:
			patience = MAX_PATIENCE
			# Increase frequency of status and movement
			min_random_interval -= 2
			if min_random_interval < 1:
				min_random_interval = 1
			max_random_interval -= 1
			if max_random_interval < 1:
				max_random_interval = 1
				print("Max random interval too low")

func get_draggable_for_status(status: String):
	if status == gameGlobals.HUNGER_STATUS:
		return !gameGlobals.is_food_bowl_draggable
	elif status == gameGlobals.THIRST_STATUS:
		return !gameGlobals.is_water_bowl_draggable
	elif status == gameGlobals.PLAY_STATUS:
		return !gameGlobals.is_toy_draggable
	else:
		return false

# Check if current status has been cured correctly
func check_is_status_cured(delta: float):
	if target_cure_status != "" and current_status != "":
		# Check status if corresponding item is not being dragged
		var is_item_placed = get_draggable_for_status(current_status)
		if is_item_placed:
			# Increase patience if correct chosen and placed (i.e. not being dragged)
			if target_cure_status == current_status:
				if not has_played_sfx_sound:
					sfx_player.stream = status_curing_sfx_dict[current_status]
					sfx_player.play()
					has_played_sfx_sound = true
				patience += patience_increment_rate * delta
				if patience >= MAX_PATIENCE:
					patience = MAX_PATIENCE
			else:
				patience -= patience_reduction_rate * delta * WRONG_ITEM_PATIENCE_REDUCE_FACTOR
			is_attempting_cure_status = true
	elif current_status != "":
		patience -= patience_reduction_rate * delta

func show_affection(delta: float) -> void:
	if current_status == gameGlobals.AFFECTION_STATUS:
		patience += AFFECTION_PATIENCE_INCREMENT
		print("Showing affection")

# Function to update the target cure status based on colliding items
func update_target_cure_status():
	var found_current_status_cure = false
	for item in colliding_items:
		var potential_cure_status = item_status_dict[item]
		
		# Prioritize curing the current status
		if potential_cure_status == current_status:
			target_cure_status = potential_cure_status
			found_current_status_cure = true
			break  # Exit early since we found the cure for the current status
		
		# If no current status cure found yet, set target_cure_status to another valid item
		if not found_current_status_cure:
			target_cure_status = potential_cure_status

	# If no items colliding, reset target_cure_status
	if not found_current_status_cure and colliding_items.is_empty():
		target_cure_status = ""

# Check what has entered our Area2D node
func _on_animal_action_area_area_entered(area):
	if area.name in item_status_dict:
		colliding_items.append(area.name)
		# Check if any colliding items can cure the status
		update_target_cure_status()
	elif area.name == "AnimalActionArea":
		print("Colliding with animal")
		current_status = gameGlobals.ANGER_STATUS
		status_icon.show_icon(current_status)
		sfx_player.stream = anger_sfx
		sfx_player.play()

# Check what has exited our Area2D node
func _on_animal_action_area_area_exited(area):
	if area.name in item_status_dict:
		# Remove the item from the list
		colliding_items.erase(area.name)

		# Check again if any remaining items can cure the status, reset if curing item has been removed
		if item_status_dict[area.name] == current_status:
			reset_status()
		update_target_cure_status()

		is_attempting_cure_status = false
		has_played_sfx_sound = false

	if area.name == "AnimalActionArea":
		reset_status()
		set_random_status()

# Check if mouse is inside our Area2D node
func _on_animal_action_area_mouse_entered():
	cursor_on_animal = true

# Check if mouse has exited our Area2D node
func _on_animal_action_area_mouse_exited():
	cursor_on_animal = false
