extends Node


func _ready():
	get_tree().change_scene_to(load(Save.config.last_scene))
