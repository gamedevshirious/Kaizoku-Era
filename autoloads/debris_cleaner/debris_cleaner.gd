extends Node
#
#func add_debri(debri):
#	get_tree().get_root().call_deferred("add_child", debri)
##
#func clear_all():
#	for debri in get_tree().get_root().get_children():
#		if debri.is_in_group("debri"):
#			debri.queue_free()
#

func _on_Timer_timeout():
	var debris = get_tree().get_root().get_children()
	var r_child = globals.random_choice(debris)
	while !r_child.is_in_group("debri"):
		r_child = globals.random_choice(debris)
	
	r_child.queue_free()
	print_debug("debri cleaned: " + str(r_child))
