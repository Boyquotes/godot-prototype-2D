extends Area2D

func _on_StaticSpikeTrap_body_entered(body):
	if !Global.player_invincible:
		body.Damage()
