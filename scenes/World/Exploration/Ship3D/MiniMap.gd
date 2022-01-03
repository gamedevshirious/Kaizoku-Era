extends Camera

var min_height = 20
var speed = 0
onready var target = get_node("../../../../../..")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	speed = target.forward_speed / 2
	var height = speed * 2 + min_height
	translation = Vector3(target.translation.x, height, target.translation.z)
	
