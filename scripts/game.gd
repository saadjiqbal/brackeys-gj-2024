extends Node2D

# Functionality will be something like using RNG to spawn
# animals.
#
# Multiple animals & different animals as the levels progress.
var dog_scene = preload("res://scenes/dog.tscn")

func _ready() -> void:
	var dog_scene_instance = dog_scene.instantiate()
	add_child(dog_scene_instance)
