extends KinematicBody2D

onready var animator = $AnimatedSprite
onready var coyoteTimer = $CoyoteTimer
onready var bulletPos = $BulletPosition2D
onready var hitPos = $HitPosition2D

#movement
var move = null
var speed = 130
var jumpForce = -350
var jumping = false
var jumpAvailable = true
var velocity = Vector2()
var dashing = false
var canDash = null
#health related
var maxHealth = 3
var testHealth = 0
var health = maxHealth
var damaged = false
var dead = false
#other stuff
const gravity = 20
var on_ground = true
var SpawnPoint = Vector2(75, 248)
#shoot
const bullet = preload("res://Scenes/Player/Bullet.tscn")
const JUMP_DUST = preload("res://Scenes/Player/JumpDust.tscn")
export var hitParticle : PackedScene
var canShoot = true

func _process(_delta):
	_Invincible()
	_Animations() 
	_Flip()
	
func _physics_process(_delta):
	print(maxHealth)
	_Collision()
	_CoyoteJump()
	_GroundCheck()
	_Input()	
	_Jump()
	_Shoot()
	if dashing:
		velocity.y = 0
	elif not dashing and not damaged:
		velocity.y += gravity

func _Input():
	if !dead and !damaged:
		move = (
			Input.get_action_strength("ui_right") -
			Input.get_action_strength("ui_left")
		)
		speed = 130 if not dashing else 500
		velocity.x = move * speed

	Dash()

	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

func Dash():
	if on_ground:
		canDash = true

	if Input.is_action_just_pressed("dash") and canDash and move!=0:
		#velocidade do dash está a ser imposta na função Input
		dashing = true
		Global.player_dashing = true #variavel usada no enemybase
		canDash = false
		yield(get_tree().create_timer(.2),'timeout')
		dashing = false
		Global.player_dashing = false
		canDash = true
	
func _Flip():
	if velocity.x < 0:
		animator.flip_h = true
		if bulletPos.position.x >= -1:
			bulletPos.position.x *= -1
	elif velocity.x > 0:
		animator.flip_h = false
		if bulletPos.position.x <= -1:
			bulletPos.position.x *= -1

func _Jump():
	var particle = JUMP_DUST.instance()
	particle.global_position = hitPos.global_position
	if Input.is_action_just_pressed("jump"):
		if jumpAvailable and !dead:
			get_parent().add_child(particle)
			velocity.y = jumpForce
			jumping = true
	if on_ground and !Input.is_action_just_pressed("jump"):
		jumping = false

# coyote jump
func _on_CoyoteTimer_timeout():
	jumpAvailable = false
	
func _CoyoteJump():
	if on_ground:
		jumpAvailable = true
	elif jumpAvailable && coyoteTimer.is_stopped():
		coyoteTimer.start()

func _Animations():
	if !damaged and !dead and !jumping:
		if velocity.x != 0:
			animator.play('run')
		elif velocity.x == 0:
			animator.play("idle")
	elif damaged and !dead:
		animator.play('hit')
		
	if dead:
		animator.play('die')

	if !damaged and !dead:
		if !on_ground:
			if velocity.y < 0:
				animator.play('jump')
			elif velocity.y > 0:
				animator.play('fall')

func _GroundCheck():
	if is_on_floor():
		on_ground = true
	elif !is_on_floor():
		on_ground = false

func _Shoot():
	if $BulletTimer.is_stopped():
		canShoot = false
		return
	else:
		if Input.is_action_just_pressed("fire"):
			var bullet2 = bullet.instance()
			if sign(bulletPos.position.x) == 1:
				bullet2._setBulletDirection(1)
			else:
				bullet2._setBulletDirection(-1)
			bullet2.position = bulletPos.global_position
			get_parent().add_child(bullet2)

func Damage():
	if !damaged:
		damaged = true
		health -= 1
		if health <= 0:
			Die()
		var hitParticle_Instance = hitParticle.instance()
		hitParticle_Instance.position = hitPos.position
		add_child(hitParticle_Instance)
		yield(get_tree().create_timer(.3), "timeout")
		damaged = false

func Die():
	dead = true
	Global.player_dead = true
	get_node("playerHurtbox/collider").set_deferred('disabled', true)
	get_node("CollisionShape2D").set_deferred('disabled', true)
	velocity = Vector2.ZERO
	yield(get_tree().create_timer(1), "timeout")
	Global.player_dead = false
	get_tree().reload_current_scene()

func _Invincible():
	# se for invencivel , hurtbox é desligado, mais umas propriedades dos inimigos, que estão no script enemybase
	if $InvincibleTimer.is_stopped():
		Global.player_invincible = false
		get_node("playerHurtbox/collider").set_deferred('disabled', false)
		set_modulate(Color(1,1,1,1))
		return
	else:
		Global.player_invincible = true
		get_node("playerHurtbox/collider").set_deferred('disabled', true)
		set_modulate(Color(1,1,1,0.3))

#função que trata da colisão com os inimigos e plataformas que caiem
func _Collision():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var collider = collision.collider
		#plataformas que caiem
		if collider.has_method('collide_with'):
			collision.collider.collide_with(collision, self)
		#inimigos
		var is_stomping = (
			collider is enemyBase and
			is_on_floor() and
			collision.normal.is_equal_approx(Vector2.UP)
		)
		
		if is_stomping:
			velocity.y = -300
			(collider as enemyBase).Die()

#colisões
func _on_playerHurtbox_body_entered(_body):
	if dashing: return
	Damage()

# função que trata de todos os itens colecionaveis
# o script collectible emite um sinal com o tipo de powerup
func on_collected(type):
	match type:
		0:
			# coin
			Global.coins += 1
			# apple (vida extra)
		1:
			if maxHealth < 5:
				maxHealth+=1
		2:
			#Poção de vida
			if health <3 :
				health +=1
		3:
			#Meat - Invencibilidade durante 5 segundos
			$InvincibleTimer.start()
		4:
			#bullet - o jogador pode disparar durante 5 segundos
			$BulletTimer.start()
			canShoot = true
