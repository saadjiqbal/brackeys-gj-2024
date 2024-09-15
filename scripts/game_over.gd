extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	game_over()
	
func game_over() -> void:
	if gameGlobals.game_over:
		self.visible = true

func retry_game() -> void:
	mainMusic.play()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_retry_pressed():
	retry_game()

func _on_exit_button_pressed():
	get_tree().quit()
