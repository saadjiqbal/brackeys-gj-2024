extends CanvasLayer

const AUDIO_SCALE_ON_MUTE: Vector2 = Vector2(0.45, 0.45)

@onready var pause_background = $PauseBackground
@onready var pause_button = $PauseMarginContainer/PauseButton
@onready var audio_button = $AudioMarginContainer/AudioButton
@onready var pause_margin_container = $PauseMarginContainer
@onready var audio_margin_container = $AudioMarginContainer

var pause_scale_on_load: Vector2
var audio_scale_on_load: Vector2

var audio_muted: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_button.visible = true
	audio_button.visible = true
	pause_background.visible = false
	
	pause_scale_on_load = pause_margin_container.scale
	audio_scale_on_load = audio_margin_container.scale

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause_game()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume_game()

func pause_game() -> void:
	get_tree().paused = true
	pause_background.visible = true
	pause_button.visible = false
	audio_button.visible = false

func resume_game() -> void:
	get_tree().paused = false
	pause_background.visible = false
	pause_button.visible = true
	audio_button.visible = true

func mute_game() -> void:
	var music_bus = AudioServer.get_bus_index("Master")
	
	AudioServer.set_bus_mute(music_bus, not AudioServer.is_bus_mute(music_bus))
	
	if !audio_muted:
		audio_button.icon = load("res://assets/ui/Icon_Small_Blank_AudioOff.png")
		audio_margin_container.scale = AUDIO_SCALE_ON_MUTE
		audio_muted = true
	else:
		audio_button.icon = load("res://assets/ui/Icon_Small_Blank_Audio.png")
		audio_margin_container.scale = audio_scale_on_load
		audio_muted = false

func _on_resume_button_pressed():
	resume_game()

func _on_options_button_pressed():
	pass # Replace with function body.

func _on_exit_button_pressed():
	get_tree().quit()

func _on_pause_button_pressed():
	pause_game()

func _on_audio_button_pressed():
	mute_game()
