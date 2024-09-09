extends CharacterBody2D

# Properties
var patience: float = 100.0  # A patience meter starting at 100
var hunger: float = 0.0      # Hunger level
var thirst: float = 0.0      # Thirst level
var playfulness: float = 0.0 # Playfulness level

# Statuses
var statuses: Array = ["hunger", "thirst", "play"]  # Possible statuses

# RNG to determine which status is affecting the animal
var current_status: String = ""

# Constants
const MAX_PATIENCE = 100.0
const MIN_PATIENCE = 0.0

# Called when the node enters the scene
func _ready():
	# Initialize the patience meter and status randomly
	current_status = get_random_status()

func _process(delta):
	# Decrease patience over time
	patience -= delta * 10  # Decrease patience by a rate
	check_patience()

	# Periodically change status based on randomness
	if patience <= 50:  # Randomize a status based on certain conditions
		current_status = get_random_status()

	# Implement behavior based on the current status
	match current_status:
		"hunger":
			hunger += delta * 5
		"thirst":
			thirst += delta * 5
		"play":
			playfulness += delta * 5

# Function to handle random status selection
func get_random_status() -> String:
	var rand_index = randi() % statuses.size()
	return statuses[rand_index]

# Function to check and respond to patience level
func check_patience():
	if patience <= MIN_PATIENCE:
		handle_patience_loss()

func handle_patience_loss():
	# Implement what happens when patience runs out, such as triggering an event
	patience = MAX_PATIENCE  # Reset patience, or handle it differently
	print("Patience ran out! The animal is unhappy.")
