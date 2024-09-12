extends Control

const SCALE_ON_HOVER: Vector2 = Vector2(0.55, 0.55)

@onready var blur_animation = $BlurAnimation
@onready var pause_background = $PauseBackground
@onready var pause_button = $MarginContainer/PauseButton
@onready var margin_container = $MarginContainer

var scale_on_load: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_button.visible = true
	pause_background.visible = false
	
	scale_on_load = margin_container.scale

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause_game()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume_game()
	
	check_pause_hover()

func pause_game() -> void:
	get_tree().paused = true
	pause_background.visible = true
	pause_button.visible = false

func resume_game() -> void:
	get_tree().paused = false
	pause_background.visible = false
	pause_button.visible = true

func check_pause_hover() -> void:
	if pause_button.is_hovered():
		margin_container.scale = SCALE_ON_HOVER
	else:
		margin_container.scale = scale_on_load

func _on_resume_button_pressed():
	resume_game()

func _on_options_button_pressed():
	pass # Replace with function body.

func _on_exit_button_pressed():
	get_tree().quit()

func _on_pause_button_pressed():
	pause_game()
