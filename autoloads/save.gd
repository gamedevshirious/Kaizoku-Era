extends Node

var SAVFILE = "res://save_file.sav"
var delete = false

var config = {
	"global_position": "Vector2(0, 0)",
	"global_transform": "Transform( 1, 0, 0, 0, 1, 0, 0, 0, 1, 350.341, 0, 40.778 )",
	"rotation_degrees": "Vector3(0, 0, 0)",
	"last_scene": "res://scenes/Utility/MainMenu/MainMenu.tscn",
	"name": "John Doe",
	"ship_name": "Bizzare Adventures",
	"crew_name": "Deadly Kaizoku",
	"music": true,
	"sound": true,
	"ship": {
		"sail": "basic",
		"rudder": "basic",
		"quater_deck": "basic",
		"mast": "basic",
		"jolly_roger": "basic",
		"hull": "basic",
		"head": "basic",
		"crows_nest": "basic"
	},
	"attacks": {
		"left_click": "punch",
		"left_hold": "",
		"right_click": "",
		"right_hold": ""
	},
	"costume": {
		"hat": "basic",
		"head": "basic",
		"torso": "basic",
		"l_upper":"basic",
		"l_lower": "basic",
		"l_thigh": "basic",
		"l_leg": "basic",
		"r_upper":"basic",
		"r_lower": "basic",
		"r_thigh": "basic",
		"r_leg": "basic" 
	},
	"pose": {
		"hat": 0,
		"head": 0,
		"torso": 0,
		"l_upper": 0,
		"l_lower": 0,
		"l_thigh": 0,
		"l_leg": 0,
		"r_upper": 0,
		"r_lower": 0,
		"r_thigh": 0,
		"r_leg": 0,
		"cc_flip": false 
	}
}

var password = "" 

func _ready():
	var dir = Directory.new()
	if delete:
		dir.remove(SAVFILE) 
	password = OS.get_unique_id()
	if password == "":
		password = "aihhiadiafioaodapodaojpdoj"
	load_data()

func save_data():
	var save_file = File.new()
	save_file.open_encrypted_with_pass(SAVFILE, File.WRITE, password)
	save_file.store_line(to_json(config))
	save_file.close()
	load_data()

func load_data():
	var save_file = File.new()
	if not save_file.file_exists(SAVFILE):
		save_data()	
	save_file.open_encrypted_with_pass(SAVFILE, File.READ, password)
	config = parse_json(save_file.get_line())
	save_file.close()
	globals.load_game()
