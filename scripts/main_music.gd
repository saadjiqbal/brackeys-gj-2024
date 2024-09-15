extends AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready():
	self.play()


func _stop_music():
	self.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_finished():
	self.play()
