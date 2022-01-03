extends RigidBody2D
#
var thrown = false
export var type = "bomb"
var can_poison = false
#var facing_dir = 1
#
#func _physics_process(delta):
#	if thrown:
#		add_force(Vector2(), Vector2(facing_dir * 1000, -500) * delta)

func _ready():
	$sprite.texture = load(globals.Paths.bomb + type + ".png")
	match type:
		"bomb":
			$smoke.queue_free()
	
	
			
func throw():
	yield(get_tree().create_timer(2), "timeout")

	if type == "":
		queue_free()
		return

	$sprite.visible = false
	$CollisionShape2D.disabled = true

	match type:
		"poison":
			var prev_pos = global_position.y - 250
# warning-ignore:unused_variable
			for x in range(10):
				var pos = prev_pos + 25
				var smoke = $smoke/smoke.duplicate()
				smoke.get_node("sprite").self_modulate = Color("82059800")
				smoke.get_node("PoisonArea").connect("body_entered", self, "_on_PoisonArea_body_entered")
				smoke.get_node("PoisonArea").connect("body_exited", self, "_on_PoisonArea_body_entered")
				smoke.get_node("PoisonArea").monitoring = true
				get_tree().get_root().add_child(smoke)
				smoke.global_position = global_position - Vector2(0, pos)
				prev_pos = global_position.y - pos
				smoke.visible = true
				
#				print(smoke.global_position)
#				print(global_position)
				yield(get_tree().create_timer(.1), "timeout")
	
			yield(get_tree().create_timer(5), "timeout")

			for child in get_tree().get_root().get_children():
				if !is_instance_valid(child):
					continue
#				print_debug(child.get_class())
				if child.name.begins_with("smoke") or child.name.begins_with("@smoke"):
#					print_debug(child.get_class())
					yield(get_tree().create_timer(1), "timeout")
					if is_instance_valid(child):
						child.queue_free()
				
		
		"smoke":
			var prev_pos = global_position.y - 250
# warning-ignore:unused_variable
			for x in range(10):
				var pos = prev_pos + 25
				var smoke = $smoke/smoke.duplicate()
				smoke.get_node("sprite").self_modulate = Color("ffffff")
				get_tree().get_root().add_child(smoke)
				smoke.global_position = global_position - Vector2(0, pos)
				prev_pos = global_position.y - pos
				smoke.visible = true
				
#				print(smoke.global_position)
#				print(global_position)
				yield(get_tree().create_timer(.1), "timeout")
	
			yield(get_tree().create_timer(5), "timeout")

			for child in get_tree().get_root().get_children():
				if !is_instance_valid(child):
					continue
				if child.name.begins_with("smoke") or child.name.begins_with("@smoke"):
					yield(get_tree().create_timer(1), "timeout")
					if is_instance_valid(child):
						child.queue_free()
				
#			yield(get_tree().create_timer(2), "timeout")
#			queue_free()
				
		"bomb":
				
#			particles.process_material = load("res://assets/particles/explosion.tres")
#			particles.texture = load("res://assets/art/shapes/circle.png")
#			particles.one_shot = true
#			particles.amount = 250
#			particles.explosiveness = .8
#			particles.local_coords = false
			$particles.emitting = true
			$ExplosionArea.monitoring = true
			
	yield(get_tree().create_timer(2), "timeout")
	if is_instance_valid(self):
		queue_free()

func _on_ExplosionArea_body_entered(body):	
	if body.get_node("../../") != null and body.get_node("../../").has_method("set_rigid"):
		body.get_node("../../").set_rigid()
		
	if body.has_method("hit"):
		var dmg = 30 - abs((body.global_position - global_position).length()) / 10
		body.hit(dmg)
		
	if body.is_class("RigidBody2D"):
		var dir = body.global_position - global_position
		body.apply_impulse(Vector2(), dir * 50)
		


func _on_PoisonArea_body_entered(body):
	if can_poison:
		if body.has_method("hit"):
			body.hit(2)
			
		if body.get_node("../../").has_method("hit"):
			body.get_node("../../").hit()


func _on_Timer_timeout():
	can_poison = !can_poison
