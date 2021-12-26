extends Area2D

func _on_Apple_body_entered(body):
	if Global.player.maxHealth <5:
		Global.player.maxHealth +=1
		$AnimationPlayer.play("collected")
