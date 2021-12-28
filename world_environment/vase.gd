extends Area2D

func _on_Vaso_body_entered(body):
	$collider.set_deferred("disabled", true)
	$AnimationPlayer.play("destroy")
