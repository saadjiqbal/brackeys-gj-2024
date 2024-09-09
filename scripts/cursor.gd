extends Node2D

@onready var click_sfx = $ClickSFX
@onready var click_particles = $ClickParticles

var mouse_cursor_image = load("res://assets/cursor/cursor.png")

func _ready() -> void: 
	Input.set_custom_mouse_cursor(mouse_cursor_image)

func _physics_process(_delta) -> void:

	if Input.is_action_just_pressed("action"):
		click_particles.position = get_global_mouse_position()
		click_particles.emitting = true

		click_sfx.play()
		

		
