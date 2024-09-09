extends Node2D

var dog_scene = preload("res://scenes/dog.tscn")

func _ready() -> void:
	var dog_scene_instance = dog_scene.instantiate()
	add_child(dog_scene_instance)
