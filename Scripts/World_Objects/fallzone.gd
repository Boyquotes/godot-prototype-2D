extends Area2D

func _on_Fallzone_body_entered(body):
	if body.name == 'Player':
		Global.player_dead = true
		yield(get_tree().create_timer(1), "timeout")
		get_tree().reload_current_scene()
