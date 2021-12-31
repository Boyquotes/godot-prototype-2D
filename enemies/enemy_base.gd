extends KinematicBody2D
class_name enemyBase

var velocity = Vector2()
var speed = 30
var moveDirection = 1
var maxHealth = 1
var health = maxHealth
var dead = false
var idle = false

func _process(_delta):
	_playerInvincible()
	_Flip()
	_set_Animations()

func _physics_process(_delta):
	if !dead:
		velocity.x = speed * moveDirection
		velocity = move_and_slide(velocity, Vector2.UP)
	_checkSurroundings()

func _set_Animations():
	if !dead and !idle:
		$AnimationPlayer.play("walk")

func _Flip():
	if velocity.x > 0:
		$Sprite.flip_h = false
	elif velocity.x < 0:
		$Sprite.flip_h = true
		
func _checkSurroundings():
	# quando o inimigo encontra uma parede ou fim da plataforma
	# entra em idle e continua o patrol
	if !$groundRayCast.is_colliding() or $wallRayCast.is_colliding():
		speed = 0
		if $AnimationPlayer.has_animation("idle"):
			idle = true
			$AnimationPlayer.play("idle")
		$groundRayCast.position.x *= -1
		$wallRayCast.scale.x *= -1
		moveDirection *= -1
		yield(get_tree().create_timer(1), "timeout")
		idle = false
		speed = 30

func die():
	#Esta função está a ser chamada no objeto player
	dead = true
	get_node("CollisionShape2D").set_deferred('disabled', true)
	$AnimationPlayer.play("death")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'death':
		queue_free()
		
func _on_EnemyHitbox_area_entered(area):
	if area.name == "Bullet":
		die()

func _playerInvincible():
	if !dead:
		if Global.player_invincible or Global.player_dashing:
			set_collision_mask_bit(0,false)
		else:
			set_collision_mask_bit(0,true)

