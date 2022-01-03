extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var costume_dict = {}
var preset_menu_popup

# Called when the node enters the scene tree for the first time.
func _ready():
#	$mesh/AnimationTree.active = true
	
	preset_menu_popup = $Preset.get_popup()
	preset_menu_popup.connect("id_pressed", self, "_on_item_pressed")
	
	for key in Inventory.costumes.keys():
		preset_menu_popup.add_item(key.replace('-',' ').capitalize())
	
	load_ready()
	
func load_ready():
	costume_dict = {}
	for item in globals.node_paths:
		costume_dict[item] = []
		
	load_costume()
	
	for item in costume_dict.keys():
		load_array(item)
	
	load_costume_container()
		
	for item in costume_dict.keys():
# warning-ignore:return_value_discarded
		$Sliders.get_node(item).connect("value_changed", self, "update_slider", [item])
		$Sliders.get_node(item).value = Save.config.pose[item]
		get_node(globals.node_paths[item]).rotation_degrees = Save.config.pose[item]
	
	add_pose()
	
#	for id in costume_dict.keys():
#		idx[id] = costume_dict[id].find(Save.config.costume[id])

#	print_debug(costume_dict)
func update_slider(value, item):
	get_node(globals.node_paths[item]).rotation_degrees = value
	
func load_costume_container():
	for child in $CostumeContainer.get_children():
		child.queue_free()
	
	for item in costume_dict.keys():
#		print_debug(item)
		
		var scroll_container = ScrollContainer.new()
		scroll_container.name = item.capitalize().replace("@", "")
		
		$CostumeContainer.add_child(scroll_container)
		
		var grid_container = GridContainer.new()
		grid_container.columns = 4
		scroll_container.add_child(grid_container)
				
		for costume in costume_dict[item]:
			var tex_button = TextureButton.new()
			tex_button.expand = true
			tex_button.rect_min_size = Vector2(125, 125)
			tex_button.texture_normal = load(globals.Paths[item] +"/"+ costume + ".png")
			grid_container.add_child(tex_button)
			tex_button.connect("pressed", self, "sav_sync", [item, costume])

func load_array(item):
	var path = globals.Paths[item]
	for item_name in globals.get_files_list(path):
		costume_dict[item].append(item_name)

func add_pose():
	for node_key in globals.node_paths.keys():
		var key = globals.node_paths[node_key]
		var rot_anim = key + ":rotation_degrees"
		var rot_value = get_node(key).rotation_degrees
		
		var track_idx = $mesh/AnimationPlayer.get_animation("pose").find_track(rot_anim)
		$mesh/AnimationPlayer.get_animation("pose").remove_track(track_idx)
		
		var anim = $mesh/AnimationPlayer.get_animation("pose")
		var track_index = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(track_index, rot_anim)
		
		var track_id = anim.find_track(rot_anim)
		anim.track_insert_key(track_id, 0, rot_value)
		anim.track_insert_key(track_id, 3, rot_value)
		
		Save.config.pose[node_key] = rot_value
	Save.save_data()

func load_costume():
	for item in costume_dict.keys():
		get_node(globals.node_paths[item]).texture = load(globals.Paths[item] + Save.config.costume[item] + ".png")
	
	$Sliders/cc_flip.pressed = Save.config.pose.cc_flip 
	$mesh.scale.x = -3 if Save.config.pose.cc_flip else 3
#	$player/head/hat.texture = load(globals.Paths.hat + Save.config.costume.hat + ".png")
#	$player/head.texture = load(globals.Paths.head + Save.config.costume.head + ".png")
#
#	load_wardrobe()
	Save.save_data()

#func load_wardrobe():
#	for id in costume_dict.keys():
#		get_node("VBoxContainer/" + id + "/Icon").texture_normal = load(globals.Paths[id] + Save.config.costume[id] + ".png")


func sav_sync(type, costume):
	Save.config.costume[type] = costume
	load_costume()


func _on_GoOutButton_pressed():	
	Save.save_data()
	get_parent().get_parent().player_cam.current = true
	get_parent().get_parent().player_cam.get_parent().update_costume(globals.node_paths)
	visible = false
	get_tree().paused = false

func update_preset(preset_name):
	Save.config.costume = Inventory.costumes[preset_name]
	load_costume()

func _on_item_pressed(ID):
	var item_name = preset_menu_popup.get_item_text(ID)
	item_name = item_name.to_lower().replace(' ', '-')
	update_preset(item_name)


func _on_cc_flip_toggled(button_pressed):
	Save.config.pose["cc_flip"] = button_pressed
	load_costume()
