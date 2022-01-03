extends Node

onready var player_cam = get_node("Player/Camera2D")

func _ready():
	print_debug("debri clearner started")
#	DebrisCleaner.clear_all()
	for debri in get_tree().get_root().get_children():
		if debri.is_in_group("debri"):
			debri.queue_free()
	
	print_debug("debri clearner stopped")

func _on_Port_body_entered(body):
	get_tree().change_scene(Paths.scenes.Exploration)

func _on_Training_body_entered(body):
	get_tree().change_scene(Paths.scenes.Training)


func _on_Shop_body_entered(body):
	get_tree().paused = true
	player_cam.current = false
	$HUD/CharacterCreator.load_ready()
	$HUD/CharacterCreator.visible = true
