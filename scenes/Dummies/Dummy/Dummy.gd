extends KinematicBody2D

const GRAVITY_VECTOR = Vector2(0, 980)
const UP_DIRECTION = Vector2(0, -1)

export var walk_speed = 250
export var jump_height = 500

var linear_velocity = Vector2()

export var type = ""
export var soldier_class = "empire-soldier"

var hit = false
var dir = 1
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# warning-ignore:shadowed_variable
func update_costume(node_paths, soldier_class):
	for item in node_paths.keys():
		get_node(node_paths[item]).texture = load(globals.Paths[item] + Inventory.costumes[soldier_class][item] + ".png")

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	$mesh/head/head_hitbox.connect("body_entered", self, "_on_head_hitbox_body_entered")
# warning-ignore:return_value_discarded
	$mesh/torso/torso_hitbox.connect("body_entered", self, "_on_torso_hitbox_body_entered")
	
	$mesh/head/head_hitbox.set_collision_layer_bit(1, true)
	$mesh/torso/torso_hitbox.set_collision_layer_bit(1, true)
	
	$mesh/head/hat.texture = load(globals.Paths["hat"] + "empire-soldier.png")
	
	
	var weapon = load("res://scenes/Weapons/Cutlass.tscn").instance()
	weapon.set_deferred("mode", RigidBody2D.MODE_KINEMATIC)
	weapon.get_node("collision").disabled = true 
	$mesh/l_upper/lower/weapon.call_deferred("add_child", weapon)
	weapon.position = Vector2.ZERO
	weapon.rotation = 0
	
	update_costume(globals.node_paths, soldier_class)
	
	$mesh/AnimationTree.active = true
#
	
	if type == "bowman":
		$bow.visible = true
		$Timer.wait_time = 5


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# warning-ignore:function_conflicts_variable
# warning-ignore:unused_argument
# warning-ignore:function_conflicts_variable
func hit(value = 0):
	if not hit:
		set_rigid()
	
	hit = true

func set_rigid():
	if $mesh/l_upper.is_class("RigidBody2D"):
		return
	
	$Timer.stop()
	$mesh.queue_free()
	yield(get_tree().create_timer(.01), "timeout")

	var mesh = load("res://scenes/Player/rigid_mesh.tscn").instance()
	call_deferred("add_child", mesh)
	yield(get_tree().create_timer(.01), "timeout")
#	print_debug("Set rigid called")
	$CollisionShape2D.disabled = true
	
	for child in $mesh.get_children():
		if child.is_class("RigidBody2D"):
			child.set_deferred("mode", RigidBody2D.MODE_RIGID)
	
	update_costume(globals.rigid_node_paths, soldier_class)
	
	yield(get_tree().create_timer(10), "timeout")
	if is_instance_valid(self):
		queue_free()
#	$mesh/torso.apply_central_impulse(Vector2(0, -10))
#	$mesh/torso.apply_impulse(position, Vector2(0, -500))
	
func _on_Timer_timeout():
	dir = -1 if dir == 1 else 1
	
#	$AnimationPlayer.play("stand_up")
	if type == "bowman":
		var arrow = load("res://scenes/Weapons/Arrow/Arrow.tscn").instance()
		get_tree().get_root().add_child(arrow)
		arrow.global_position = $bow.global_position
		arrow.linear_velocity = Vector2( -1000, -500)
#		arrow.apply_central_impulse(Vector2(-750, -5))
#		yield(get_tree().create_timer(15), "timeout")
#		if arrow.has_method("get_class"):
#			print_debug(arrow.get_class())
#		arrow.call_deferred("queue_free")


func _process(delta):
	if !is_instance_valid($mesh):
		return
	
	if $mesh/l_upper.is_class("RigidBody2D"):
		return
		
	linear_velocity += delta * GRAVITY_VECTOR
	linear_velocity = move_and_slide(linear_velocity, UP_DIRECTION, false)
	
	var target_speed = dir
	$mesh.scale.x = dir	
	
	var blend = abs(dir)
			
	$mesh/AnimationTree.set("parameters/body_blend/blend_amount", blend)
		
	
	target_speed *= walk_speed
	linear_velocity.x = lerp(linear_velocity.x, target_speed, 0.1)
	
	
# warning-ignore:unused_argument
func _on_head_hitbox_body_entered(body):	
	$HitLabel.text = "Critical Hit"
	$AnimationPlayer.play("show_hit")
	set_rigid()

# warning-ignore:unused_argument
func _on_torso_hitbox_body_entered(body):
	$HitLabel.text = "Hit"
	$AnimationPlayer.play("show_hit")
	set_rigid()

