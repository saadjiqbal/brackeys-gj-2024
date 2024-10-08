extends Node2D

const HUNGER_STATUS = "hunger"
const THIRST_STATUS = "thirst"
const PLAY_STATUS = "play"
const AFFECTION_STATUS = "affection"
const ANGER_STATUS = "anger"

const MAX_LEVEL: int = 3

var can_drag_item: bool = true
var is_water_bowl_draggable: bool = true
var is_food_bowl_draggable: bool = true
var is_toy_draggable: bool = true

var current_level: int = 1

var hotbar_size: int = 3

var playback_position: float

var game_over: bool = false
var game_win: bool = false
