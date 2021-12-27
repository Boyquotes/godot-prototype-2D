extends KinematicBody2D

const gravity = 20
const Bullet = preload("res://Scenes/Player/Bullet.tscn")
const Jump_Dust = preload("res://Scenes/Player/JumpDust.tscn")
const Hit_Particle = preload("res://Scenes/Player/hitParticle.tscn")

# movement
var move = null
var speed = 130
var jump_force = -350
var jumping = false
var jump_available = true
var velocity = Vector2()
var dashing = false
var can_dash = null

# health related
var max_health = 3
var health = max_health
var damaged = false
var dead = false

# other stuff
var on_ground = true
var can_shoot = true

# nodes
onready var animator = $AnimatedSprite
onready var coyoteTimer = $CoyoteTimer
onready var bulletPos = $BulletPosition2D
onready var hitPos = $HitPosition2D

func _process(_delta):
	invincible()
	animations() 
	flip()
	
func _physics_process(_delta):
	collision()
	coyotejump()
	ground_check()
	input()	
	jump()
	shoot()
	
	if dashing:
		velocity.y = 0
	elif not dashing and not damaged:
		velocity.y += gravity

func input():
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
		can_dash = true

	if Input.is_action_just_pressed("dash") and can_dash and move!=0:
		# velocidade do dash está a ser i posta na função Input
		dashing = true
		Global.player_dashing = true #variavel usada no enemybase
		can_dash = false
		yield(get_tree().create_timer(.2),'timeout')
		dashing = false
		Global.player_dashing = false
		can_dash = true
	
func flip():
	if velocity.x < 0:
		animator.flip_h = true
		if bulletPos.position.x >= -1:
			bulletPos.position.x *= -1
	elif velocity.x > 0:
		animator.flip_h = false
		if bulletPos.position.x <= -1:
			bulletPos.position.x *= -1

func jump():
	var particle = Jump_Dust.instance()
	particle.global_position = hitPos.global_position

	if Input.is_action_just_pressed("jump"):
		if jump_available and !dead:
			get_parent().add_child(particle)
			velocity.y = jump_force
			jumping = true

	if on_ground and !Input.is_action_just_pressed("jump"):
		jumping = false

# coyote jump
func _on_CoyoteTimer_timeout():
	jump_available = false
	
func coyotejump():
	if on_ground:
		jump_available = true
	elif jump_available && coyoteTimer.is_stopped():
		coyoteTimer.start()

func animations():
	if !damaged and !dead:
		if !jumping:
			if velocity.x != 0:
				animator.play('run')
			elif velocity.x == 0:
				animator.play("idle")
		if !on_ground:
			if velocity.y < 0:
				animator.play('jump')
			elif velocity.y > 0:
				animator.play('fall')
		
	elif damaged and !dead:
		animator.play('hit')

	if dead:
		animator.play('die')	

func ground_check():
	on_ground = true if is_on_floor() else false	

func shoot():
	if $BulletTimer.is_stopped():
		can_shoot = false
		return
	else:
		if Input.is_action_just_pressed("fire"):
			var bullet2 = Bullet.instance()
			if sign(bulletPos.position.x) == 1:
				bullet2._setBulletDirection(1)
			else:
				bullet2._setBulletDirection(-1)
			bullet2.position = bulletPos.global_position
			get_parent().add_child(bullet2)

func damage():
	if !damaged:
		damaged = true
		health -= 1
		if health <= 0:
			die()
		var hit_particle_instance = Hit_Particle.instance()
		hit_particle_instance.position = hitPos.position
		add_child(hit_particle_instance)
		yield(get_tree().create_timer(.3), "timeout")
		damaged = false

func die():
	dead = true
	Global.player_dead = true
	get_node("playerHurtbox/collider").set_deferred('disabled', true)
	get_node("CollisionShape2D").set_deferred('disabled', true)
	velocity = Vector2.ZERO
	yield(get_tree().create_timer(1), "timeout")
	Global.player_dead = false
	get_tree().reload_current_scene()

func invincible():
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
func collision():
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
			(collider as enemyBase).die()

#colisões
func _on_playerHurtbox_body_entered(_body):
	return dashing
	damage()
