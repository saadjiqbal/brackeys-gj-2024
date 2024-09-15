extends CanvasLayer

signal level_finished

const LEVEL_TIME_ARRAY: Array = [10, 10, 10]

@onready var timer_label = $MarginContainer/TimerLabel
@onready var timer = $Timer


var is_level_finished: bool = false

func _ready() -> void:
	timer.set_wait_time(10)
	timer.start()
	set_level_timer()

func _process(_delta) -> void:
	update_timer_label()
	
	if is_level_finished and not gameGlobals.game_over:
		set_level_timer()
	elif gameGlobals.game_over:
		stop_level_timer()

func set_level_timer() -> void:
	# Functionality in here to check level and then set the appropriate time
	if (gameGlobals.current_level - 1) >= LEVEL_TIME_ARRAY.size():
		print("Out of bounds, check current_level var")
	else:
		timer.set_wait_time(float(LEVEL_TIME_ARRAY[gameGlobals.current_level - 1]))
		timer.start()
		
		is_level_finished = false

func stop_level_timer() -> void:
	timer.stop()

func update_timer_label() -> void:
	timer_label.text = str(int(timer.time_left))

func _on_timer_timeout():
	level_finished.emit()
	is_level_finished = true
