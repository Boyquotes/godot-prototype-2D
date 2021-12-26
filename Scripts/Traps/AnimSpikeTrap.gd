extends Area2D

onready var anim = $AnimationPlayer

func _on_Timer_timeout():
	anim.play("attack")

func _on_Area2D_body_entered(body):
	if !Global.player_invincible:
		body.Damage()
