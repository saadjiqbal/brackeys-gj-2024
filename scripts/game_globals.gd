extends Node2D

const HUNGER_STATUS = "hunger"
const THIRST_STATUS = "thirst"
const PLAY_STATUS = "play"
const AFFECTION_STATUS = "affection"

var can_drag_item : bool = true
var is_affection_cursor_selected: bool = true  # Set to false to use cursor to move dog
