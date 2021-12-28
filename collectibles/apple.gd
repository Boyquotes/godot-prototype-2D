extends Area2D

func _on_Apple_body_entered(body):
	if Global.player.max_health <5:
		Global.player.max_health +=1
		$AnimationPlayer.play("collected")
