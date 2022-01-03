extends RigidBody2D

var target

func _ready():
	pass


func _on_Area2D_body_entered(body):
	$Area2D.queue_free()
#	print_debug(body.name)
	var prev_global_pos = global_position
	var prev_global_rot = global_rotation
	target = $sprite
#	linear_velocity = Vector2.ZERO
	$CollisionShape2D.queue_free()
	
	remove_child(target)
		
	if body.get_node_or_null("mesh"):
		body.get_node("mesh").add_child(target)
	else:
		body.add_child(target)
	
	target.global_position = prev_global_pos
	target.global_rotation = prev_global_rot
	set_deferred("mode", RigidBody2D.MODE_STATIC)
	
	yield(get_tree().create_timer(8), "timeout")

	if is_instance_valid(target):
		if body.get_node_or_null("mesh"):
			body.get_node("mesh").remove_child(target)
		else:
			body.remove_child(target)
			
		get_tree().get_root().add_child(target)
		yield(get_tree().create_timer(2), "timeout")
		queue_free()


