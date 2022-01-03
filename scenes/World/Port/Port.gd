extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var scene_path = "res://scenes/World/Islands/"

# Called when the node enters the scene tree for the first time.
func _ready():
	scene_path = scene_path + get_parent().name + "/2D.tscn"


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Port_body_entered(_body):
	get_tree().change_scene(scene_path)
