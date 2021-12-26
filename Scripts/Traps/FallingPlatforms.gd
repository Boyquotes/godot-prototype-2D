extends KinematicBody2D

onready var anim = $AnimationPlayer

var velocity = Vector2()
var gravity = 720
var isTriggered = false

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	velocity.y += gravity * delta
	position += velocity * delta

func collide_with(_collision: KinematicCollision2D, _collider: KinematicBody2D):
	if !isTriggered:
		isTriggered = true
		anim.play("trigger")

func _on_AnimationPlayer_animation_finished(_anim_name):
	set_physics_process(true)
	yield(get_tree().create_timer(10),"timeout")
	queue_free()
