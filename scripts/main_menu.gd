extends Control

@onready var audio_stream_player_2d = $AudioStreamPlayer2D
@onready var main_menu_music = $MainMenuMusic

# Called when the node enters the scene tree for the first time.
func _ready():
	main_menu_music.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_options_pressed():
	pass # Replace with function body.


func _on_exit_pressed():
	get_tree().quit()
