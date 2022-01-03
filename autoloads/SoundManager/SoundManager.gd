extends Node

var music = true
var sound = false

func _ready():	
	$bg.play()
	pass

func _process(_delta):
	$bg.volume_db = int(!music)
	$sfx.volume_db = int(!sound)

func playSFX(sfx):
	if !globals.sound:
		return
	
#	$sfx.volume_db = 0
	
	match sfx:
		"default":
			continue
			
	
	$sfx.play()


func _on_sfx_finished():
	$sfx.stop()
