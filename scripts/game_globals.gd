extends Node2D

const HUNGER_STATUS = "hunger"
const THIRST_STATUS = "thirst"
const PLAY_STATUS = "play"
const AFFECTION_STATUS = "affection"

const MAX_LEVEL: int = 3

var can_drag_item: bool = true
var is_affection_cursor_selected: bool = false  # Set to false to use cursor to move dog

var current_level: int = 1
var is_game_finished: bool = false

var hotbar_size: int = 3
