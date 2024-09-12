extends Control

var startButtonRef
var startGameLabelRef
var quitGameButtonRef
var restartButtonRef
var gameOverLabelRef

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startButtonRef = find_child("Start button")
	quitGameButtonRef = find_child("Quit button")
	startGameLabelRef = find_child("Start Game label")
	restartButtonRef = find_child("Restart button")
	gameOverLabelRef = find_child("Game Over label")
	
	enableGameOverScreen()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Turns the UI elements related to the start screen visible.
func enableStartScreen() -> void:
	startButtonRef.visible = true
	startGameLabelRef.visible = true
	quitGameButtonRef.visible = true

func enableGameOverScreen() -> void:
	gameOverLabelRef.visible = true
	restartButtonRef.visible = true
	quitGameButtonRef.visible = true

func hideStateScreen() -> void:
	startButtonRef.visible = false
	startGameLabelRef.visible = false
	quitGameButtonRef.visible = false
	gameOverLabelRef.visible = false
	restartButtonRef.visible = false


func _on_quit_button_pressed() -> void:
	get_tree().quit()
