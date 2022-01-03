extends KinematicBody2D

const GRAVITY_VECTOR = Vector2(0, 980)
const UP_DIRECTION = Vector2(0, -1)

export var walk_speed = 250
export var jump_height = 1000

var linear_velocity = Vector2()
var facing_dir = 1
var prev_dir = 1
var blend = 0

var curr_weapon = 0

var bomb_at_hand = "bomb"
var throw_bomb = false

func update_costume(node_paths):
	for item in node_paths.keys():
		get_node(node_paths[item]).texture = load(globals.Paths[item] + Save.config.costume[item] + ".png")

#	$mesh/head/hat.texture = load(globals.Paths.hat + Save.config.costume.hat + ".png")
#	$mesh/head.texture = load(globals.Paths.head + Save.config.costume.head + ".png")

func _ready():
	print_debug(get_tree().current_scene.filename)
	if get_tree().current_scene.filename != Save.config.last_scene:
		global_position = Vector2.ZERO
	else:
		Save.config.last_scene = get_tree().current_scene.filename
		global_position = str2var(Save.config.global_position)
	
	update_costume(globals.node_paths)
	$mesh/AnimationTree.active = true
	
# warning-ignore:return_value_discarded
	$mesh/head/head_hitbox.connect("body_entered", self, "_on_head_hitbox_body_entered")
# warning-ignore:return_value_discarded
	$mesh/torso/torso_hitbox.connect("body_entered", self, "_on_torso_hitbox_body_entered")


#func turn(dir):
#	if dir == 1:
#		#going right
#		$mesh.move_child($mesh/l_upper, 1)
#		$mesh.move_child($mesh/l_thigh, 2)
#		$mesh.move_child($mesh/r_thigh, 4)
#		$mesh.move_child($mesh/r_upper, 5)		
#	else:
#		$mesh.move_child($mesh/r_upper, 1)
#		$mesh.move_child($mesh/r_thigh, 2)
#		$mesh.move_child($mesh/l_thigh, 4)
#		$mesh.move_child($mesh/l_upper, 5)
#
#	$mesh/l_upper.scale.y = dir
#	$mesh/l_thigh.scale.x = dir
#	$mesh/r_upper.scale.y = dir
#	$mesh/r_thigh.scale.x = dir


func do_pose():
	$mesh/AnimationTree.set("parameters/somersault/active", true)
	$mesh/AnimationTree.set("parameters/somersault_blend/blend_amount", -1)
	
func do_somersault(dir):
	$mesh/AnimationTree.set("parameters/somersault/active", true)
#	var anim = $mesh/AnimationPlayer.get_animation("somersault")
#	for trk in ["l_upper", "r_upper", "l_upper/lower", "r_upper/lower"]:
#		var np = "parts/"+trk
#		var track_idx = anim.find_track(np + ":rotation_degrees")
#		anim.track_insert_key(track_idx, 1, get_node(np).rotation_degrees)
#		anim.track_insert_key(track_idx, 0, get_node(np).rotation_degrees)
#
	if dir == 0:
		if $mesh.scale.x > 0:
			$mesh/AnimationTree.set("parameters/somersault_blend/blend_amount", 1)
		else:
			$mesh/AnimationTree.set("parameters/somersault_blend/blend_amount", 0)
		return

	if $mesh.scale.x > 0:
		$mesh/AnimationTree.set("parameters/somersault_blend/blend_amount", 0)
	else:
		$mesh/AnimationTree.set("parameters/somersault_blend/blend_amount", 1)



func set_rigid():
	if $mesh/l_upper.is_class("RigidBody2D"):
		return
		
	$mesh.queue_free()
	yield(get_tree().create_timer(.01), "timeout")

	var mesh = load("res://scenes/Player/rigid_mesh.tscn").instance()
	call_deferred("add_child", mesh)
	yield(get_tree().create_timer(.01), "timeout")
	
	$CollisionShape2D.disabled = true
	update_costume(globals.rigid_node_paths)
#	print_debug("Set rigid called")

	for child in $mesh.get_children():
		if child.is_class("RigidBody2D"):
			child.set_deferred("mode", RigidBody2D.MODE_RIGID)

func _physics_process(delta):
	if $mesh/l_upper.is_class("RigidBody2D"):
		return
	# apply gravity
	linear_velocity += delta * GRAVITY_VECTOR
	linear_velocity = move_and_slide(linear_velocity, UP_DIRECTION, false)

	if Input.is_action_pressed("sprint"):
		walk_speed = 400
	else:
		walk_speed = 250

	var target_speed = 0
	if Input.is_action_pressed("ui_left"):
		target_speed -= 1
		facing_dir = -1
		$mesh.scale.x = -1
	if Input.is_action_pressed("ui_right"):
		target_speed += 1
		facing_dir = 1
		$mesh.scale.x = 1
	if prev_dir != facing_dir:
#		turn(facing_dir)
		prev_dir = facing_dir
		
	if Input.is_action_pressed("pose"):
		do_pose()
		
	if is_on_floor() and Input.is_action_pressed("sprint"):
		target_speed *= 2
		$mesh/AnimationPlayer.playback_speed = 2
	else:
		$mesh/AnimationPlayer.playback_speed = 1
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		linear_velocity.y = -jump_height/2
		
	if !is_on_floor() and Input.is_action_just_pressed("jump"):
			linear_velocity.y = -jump_height
			do_somersault(target_speed)
		
#	if !is_on_floor() and Input.is_action_just_pressed("ui_up"):
#		do_somersault(target_speed)

	if is_on_floor():
		if abs(target_speed) > 0:
			blend = lerp(blend, 1, 0.1)
		else:
			blend = lerp(blend, 0, 0.1)
	else:
		if $mesh.rotation_degrees in [0, 360, -360]:
			blend = lerp(blend, -1, 0.1)
			
	$mesh/AnimationTree.set("parameters/body_blend/blend_amount", blend)
		
	target_speed *= walk_speed
	linear_velocity.x = lerp(linear_velocity.x, target_speed, 0.1)
	
	# Attacks
	
	
	if Input.is_action_just_pressed("left_mouse"):
#		if $mesh/l_upper/lower/weapon.get_child_count() > 0:		
#			match $mesh/l_upper/lower/weapon.get_child(0).name.to_lower():
#				"cutlass":
#					curr_weapon = -.1
		
		var anim = globals.random_choice([.3, .4])		
		if Input.is_action_pressed("ui_up"):
			anim = .5
		elif Input.is_action_pressed("ui_down"):
			anim = .6
		elif abs(target_speed) > 0:
			anim = globals.random_choice([.1, .2])
		
		attack(curr_weapon, anim)
		
	
	if Input.is_action_just_pressed("throw_weapon"):
		throw_bomb = false
		attack(0, .7)
		
	if Input.is_action_just_pressed("throw_bomb"):
		throw_bomb = true
		attack(0, .8)
#		var weapon = $mesh/l_upper/lower/weapon.get_child(0)
#		reparent_weapon_to_root()
#		if weapon.is_class("RigidBody2D"):
#			weapon.mode = RigidBody2D.MODE_RIGID
		
		
#	if Input.is_action_just_pressed("right_mouse"):
#		var anim = [.1, .2][randi() % 2]
#		$mesh/AnimationTree.set("parameters/BlendSpace2D/blend_position", Vector2(-0.2, anim))
#		$mesh/AnimationTree.set("parameters/attack/active", true)
#		$mesh/AnimationPlayer.play(Save.config["attacks"]["left_click"])
#
#func _on_Port_area_entered(area):
#

func attack(weapon, anim):
	$mesh/AnimationTree.set("parameters/attack_anim/blend_position", Vector2(weapon, anim))
	$mesh/AnimationTree.set("parameters/attack/active", true)

func pick_up_weapon(weapon):
	if $mesh/l_upper/lower/weapon == null or $mesh/l_upper/lower/weapon.get_child_count() > 0:
		return
	
	if weapon.is_class("RigidBody2D"):
		weapon.set_deferred("mode", RigidBody2D.MODE_KINEMATIC)
		
	var old_parent = weapon.get_parent()
	if old_parent.name != "weapon":
		old_parent.remove_child(weapon)
		$mesh/l_upper/lower/weapon.call_deferred("add_child", weapon)
		weapon.position = Vector2.ZERO
		weapon.rotation = 0
	
	var weapon_name = weapon.name.to_lower()
	
	$HUD/WeaponPanel/Container/Weapon.texture_normal = weapon.get_node("sprite").texture
	
	match weapon_name:
		"cutlass":
			curr_weapon = -.1
	
		

func reparent_weapon_to_root(weapon, parent = "l_upper"):
	var prev_global_pos = weapon.global_position
	get_node("mesh/"+parent+"/lower/weapon").remove_child(weapon)
	get_tree().get_root().add_child(weapon)
	weapon.global_position = prev_global_pos

func throw_object(weapon):
	if weapon == null:
		return
		
	if weapon.is_class("RigidBody2D"):
		weapon.scale *= facing_dir
		weapon.set_deferred("mode", RigidBody2D.MODE_RIGID)
		
		if weapon.has_method("throw"):
			weapon.thrown = true
			weapon.throw()
			weapon.linear_velocity = Vector2(facing_dir * weapon.get_node("sprite").texture.get_width() * 10 , - weapon.get_node("sprite").texture.get_height() * 10)
		else:
			weapon.linear_velocity = Vector2(facing_dir * weapon.get_node("sprite").texture.get_width() * 10 , -300)
		

func throw_weapon():
	if throw_bomb:
		var bomb = load("res://scenes/Weapons/Bomb/Bomb.tscn").instance()
		bomb.type = bomb_at_hand
		$mesh/r_upper/lower/weapon.add_child(bomb)
		bomb.position = Vector2()
		throw_object(bomb)
		reparent_weapon_to_root(bomb, "r_upper")
		return
	
	if $mesh/l_upper/lower/weapon.get_child_count() < 1:
		return 
		
	var weapon = $mesh/l_upper/lower/weapon.get_child(0)
	throw_object(weapon)
	reparent_weapon_to_root(weapon)
	
	curr_weapon = 0
		
		
#		for i in range(1000000):
#			weapon.add_force(Vector2(), Vector2(facing_dir * .1, -10))
#			yield(get_tree().create_timer(.01), "timeout")
#		weapon.apply_central_impulse(Vector2(facing_dir * 750, -5))
		
	
#		weapon.apply_force(weapon.global_position, Vector2(facing_dir * 1000, 0))
#		weapon.apply_torque_impulse(facing_dir * 100000)

func _on_WeaponDetector_body_entered(body):
	if body.is_in_group("throwable"):
#		body.queue_free()
		if body.has_method("throw"):
			if body.thrown:
				return
			
		if body.is_in_group("held"):
			pick_up_weapon(body)
		else:
			body.queue_free()
		yield(get_tree().create_timer(1), "timeout")
		

func hit(val = 0):
	$HealthBar.value -= val
	
	if $HealthBar.value <= 0:
		set_rigid()


func _on_head_hitbox_body_entered(body):
	if body.is_in_group("weapons"):
		hit(50)


func _on_torso_hitbox_body_entered(body):
	if body.is_in_group("weapons"):
		hit(5)


func _on_Throwable_pressed():
	var bombs_arr = globals.get_files_list(globals.Paths.bomb)
	var prev_bomb = bomb_at_hand
	while bomb_at_hand == prev_bomb:
		bomb_at_hand = globals.random_choice(bombs_arr)
	var texture_path = load(globals.Paths.bomb + bomb_at_hand + ".png")
	$HUD/WeaponPanel/Container/Throwable.texture_normal = texture_path


func _on_AutoSaveTimer_timeout():
	Save.config.global_position = var2str(global_position)
	Save.config.last_scene = get_tree().current_scene.filename
	Save.save_data()
