extends Area2D

var speed = 300
var velocity = Vector2()
var direction = 1

func _setBulletDirection(dir):
	direction = dir
	if dir == 1:
		$Sprite.flip_h = false
	elif dir==-1:
		$Sprite.flip_h = true

func _physics_process(delta):
	velocity.x = speed*delta*direction
	translate(velocity)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _Collide():
	speed = 0
	$AnimationPlayer.play("collide")

#damage aos inimigos atraves de balas
func _on_Bullet_body_entered(body):
	_Collide()
	if !body.is_in_group("Enemy"):
		return
	else:
		body.Die()
