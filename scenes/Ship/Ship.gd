extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func load_ship():
	for part in $parts.get_children():
		part.texture = load("res://assets/art/ship/"+part.name+"s/"+Save.config.ship[part.name]+".png")
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	load_ship()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	position.x += 50 * delta
