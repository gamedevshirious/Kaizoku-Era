extends Area2D

var can_gift = true

func _on_Tree_body_entered(body):
	if !can_gift:
		return
	
	var gift = load("res://scenes/Objects/Gift/Gift.tscn").instance()
	get_tree().get_root().add_child(gift)
	gift.global_position = global_position
	gift.linear_velocity = Vector2( 100 * globals.random_choice([1, -1]), -1000)
	can_gift = false
	$star.visible = false

func _on_GiftTimer_timeout():
	can_gift = true
	$star.visible = true
