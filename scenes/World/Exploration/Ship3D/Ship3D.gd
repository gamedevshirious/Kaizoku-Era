extends KinematicBody

export var max_speed = 0
export var acceleration = 0.6
export var pitch_speed = 1.5
export var roll_speed = 1.9
export var yaw_speed = 0.2
export var input_response = 8.0

var velocity = Vector3.ZERO
var forward_speed = 0
var pitch_input = 0
var roll_input = 0
var yaw_input = 0
var cam_input = 0

var front_mast_open = false
var rear_mast_open = false
var main_mast_open = false

var mem_com_display = false

onready var guide = get_node("../Guide")
onready var target_island = get_node("../Islands").get_child(0)
onready var islands = get_node("../Islands")
onready var crow_nest_cam = $hull/Masts/main/crow_s_nest/Camera

var mouse_sensitivity = 0.002
var dragging = false

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				dragging = true
			else:
				dragging = false
	
	if event is InputEventMouseMotion:
		if $Gimbal/Camera.current && dragging:
			$Gimbal.rotate_y(-event.relative.x * mouse_sensitivity)
	
	
func get_input(delta):
#	if Input.is_action_just_pressed("ui_up"):
	if Input.is_action_just_pressed("toggle_mem_com"):
		mem_com_display = !mem_com_display
		if mem_com_display:
			$GUI/MemComDialog.popup()
	
	if Input.is_action_just_pressed("crow_s_nest_camera_toggle"):
		if (crow_nest_cam.current) :
			$Gimbal/Camera.current = true
			$GUI/pinhole.visible = false
		else:
			$GUI/pinhole.visible = true
			crow_nest_cam.current = true
		
	
	if Input.is_action_just_pressed("toggle_front_mast"):
		front_mast_open = !front_mast_open
	
	if Input.is_action_just_pressed("toggle_rear_mast"):
		rear_mast_open = !rear_mast_open
	
	if Input.is_action_just_pressed("toggle_main_mast"):
		main_mast_open = !main_mast_open
		
	if Input.is_action_just_pressed("toggle_all_masts"):
		if (front_mast_open and rear_mast_open and main_mast_open):
			main_mast_open = false
			front_mast_open = false
			rear_mast_open = false
		else:
			main_mast_open = true
			front_mast_open = true
			rear_mast_open = true
	
	if front_mast_open:
		$hull/Masts/front/mast.show()
	else:
		$hull/Masts/front/mast.hide()
	
	if rear_mast_open:
		$hull/Masts/rear/mast.show()
	else:
		$hull/Masts/rear/mast.hide()
	
	if main_mast_open:
		$hull/Masts/main/mast.show()
	else:
		$hull/Masts/main/mast.hide()
	
	max_speed = int(front_mast_open) * 10 + int(rear_mast_open) * 5 + int(main_mast_open) * 15
	forward_speed = lerp(forward_speed, max_speed, acceleration * delta)
	
	
	yaw_input =  lerp(yaw_input,
		Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right"), 
		input_response * delta)
	
	if (crow_nest_cam.current) :
		if Input.is_action_pressed("ui_left"):
			crow_nest_cam.rotation.y += 0.1
		if Input.is_action_pressed("ui_right"):
			crow_nest_cam.rotation.y -= 0.1
	
	$hull/cabin/rudder.rotation.y = lerp_angle(0, -yaw_input, yaw_speed)

func set_log():
#	guide.clear()
#	guide.begin(Mesh.PRIMITIVE_LINES, load("res://assets/art/shapes/square.png"))
#
#
#
#	guide.add_vertex($hull.transform.origin)
#	guide.add_vertex(target_island.transform.origin)
#
#	guide.end()
	
	$log.look_at(target_island.translation, Vector3(0, 0, 1))
	$log.rotate_object_local(Vector3(1,0,0), -PI/2)
# warning-ignore:unused_variable
	var dir = 1 
	
#	if (translation.z < 0):
#		dir = 1
#	elif (translation.x > 0):
#		dir = 1
	
		
#	$log.rotation_degrees.y += 90 * dir
#	$log.rotate_x(3.14)

func _process(delta):
	get_input(delta)
	set_log()
	
	$GUI/Minimap/VBoxContainer/PoisitionLabel.text = str(forward_speed)
	$GUI/AngleLabel.text = str(int(rotation_degrees.y))
	
	if !dragging:
		$Gimbal.rotation.y = lerp_angle($Gimbal.rotation.y, 0, 0.1)

func _physics_process(delta):
	if (front_mast_open or rear_mast_open or main_mast_open):
		transform.basis = transform.basis.rotated(transform.basis.y, 
			 yaw_input * yaw_speed * delta
		)
	transform.basis = transform.basis.orthonormalized()
	velocity = transform.basis.z * forward_speed
# warning-ignore:return_value_discarded
	move_and_collide(velocity * delta)
	



func _on_MemComDialog_id_pressed(id):
	$GUI/MemComDialog.hide()
	var island_name = $GUI/MemComDialog.get_item_text(id)
	target_island = get_node("../Islands/"+island_name)


func _on_MemComDialog_about_to_show():
	$GUI/MemComDialog.clear()
	for island in islands.get_children():
		$GUI/MemComDialog.add_item(island.name)

func _ready():
	global_transform = str2var(Save.config.global_transform)
#	rotation_degrees = str2var(Save.config.rotation_degrees)

func _on_AutosaveTimer_timeout():
	Save.config.global_transform = var2str(global_transform)
#	Save.config.rotation_degrees = var2str(rotation_degrees)
	Save.save_data()
