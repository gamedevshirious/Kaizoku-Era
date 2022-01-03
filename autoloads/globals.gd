extends Node

var Paths = {
	"hat": "res://assets/art/pirate/accessories/hats/",
	"head": "res://assets/art/pirate/head/face/",
	"torso": "res://assets/art/pirate/torso/",
	"l_upper":"res://assets/art/pirate/upper/",
	"l_lower": "res://assets/art/pirate/upper/lower/",
	"l_thigh": "res://assets/art/pirate/thigh/",
	"l_leg": "res://assets/art/pirate/thigh/leg/",
	"r_upper":"res://assets/art/pirate/upper/",
	"r_lower": "res://assets/art/pirate/upper/lower/",
	"r_thigh": "res://assets/art/pirate/thigh/",
	"r_leg": "res://assets/art/pirate/thigh/leg/",
	"bomb": "res://assets/art/weapons/bombs/"
}

var node_paths = {
	"hat": "mesh/head/hat",
	"head": "mesh/head",
	"torso": "mesh/torso",
	"l_upper":"mesh/l_upper",
	"l_lower": "mesh/l_upper/lower",
	"l_thigh": "mesh/l_thigh",
	"l_leg": "mesh/l_thigh/leg",
	"r_upper":"mesh/r_upper",
	"r_lower": "mesh/r_upper/lower",
	"r_thigh": "mesh/r_thigh",
	"r_leg": "mesh/r_thigh/leg"
}

var rigid_node_paths = {
	"hat": "mesh/head/head/hat",
	"head": "mesh/head/head",
	"torso": "mesh/torso/torso",
	"l_upper":"mesh/l_upper/l_upper",
	"l_lower": "mesh/l_upper/lower/lower",
	"l_thigh": "mesh/l_thigh/l_thigh",
	"l_leg": "mesh/l_thigh/leg/leg",
	"r_upper":"mesh/r_upper/r_upper",
	"r_lower": "mesh/r_upper/lower/lower",
	"r_thigh": "mesh/r_thigh/r_thigh",
	"r_leg": "mesh/r_thigh/leg/leg"
}


func load_game():
	SoundManager.music = Save.config["music"]
	SoundManager.sound = Save.config["sound"]

func random_choice(arr):
	return arr[randi() % arr.size()]
	
func get_files_list(path):
	var item_arr = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				file_name = dir.get_next()
				continue
			var item_name = file_name.split('.')[0]
			if not item_name in item_arr:
				item_arr.append(item_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		print(path)
	
	return item_arr
	
