extends Node2D

const HUNGER_ICON_INDEX = 0
const THIRST_ICON_INDEX = 1
const PLAY_ICON_INDEX = 2
const AFFECTION_ICON_INDEX = 3
const ANGER_ICON_INDEX = 4

var icon_images: Array[Texture2D] = [
	preload("res://assets/icons/hunger icon.png"),
	preload("res://assets/icons/thirst icon.png"),
	preload("res://assets/icons/boredom icon.png"),
	preload("res://assets/icons/affection icon.png"),
	preload("res://assets/icons/anger icon.png")
]
var current_image_index = 0
var sprite: Sprite2D

func _ready():
	sprite = $Sprite2D

func select_texture(status: String) -> bool:
	var is_valid_status: bool = false
	if status == gameGlobals.HUNGER_STATUS:
		current_image_index = HUNGER_ICON_INDEX
		is_valid_status = true
	elif status == gameGlobals.THIRST_STATUS:
		current_image_index = THIRST_ICON_INDEX
		is_valid_status = true
	elif status == gameGlobals.PLAY_STATUS:
		current_image_index = PLAY_ICON_INDEX
		is_valid_status = true
	elif status == gameGlobals.AFFECTION_STATUS:
		current_image_index = AFFECTION_ICON_INDEX
		is_valid_status = true
	elif status == gameGlobals.ANGER_STATUS:
		current_image_index = ANGER_ICON_INDEX
		is_valid_status = true
	sprite.texture = icon_images[current_image_index]
	return is_valid_status

func show_icon(status: String):
	if select_texture(status):
		visible = true

func hide_icon():
	visible = false
