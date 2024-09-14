extends Node2D

const HUNGER_STATUS = "hunger"
const THIRST_STATUS = "thirst"
const PLAY_STATUS = "play"
const AFFECTION_STATUS = "affection"

const MAX_LEVEL: int = 3

var can_drag_item: bool = true

var current_level: int = 1
var is_game_finished: bool = false

var hotbar_size: int = 3

var playback_position: float

var game_over: bool = false
var game_win: bool = false
