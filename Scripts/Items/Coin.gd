extends Area2D

func _on_Apple_body_entered(body):
	Global.coins +=1
	$AnimationPlayer.play("collected")
