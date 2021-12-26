extends Node2D

onready var platform = $platform
onready var tween = $Tween

export var horizontalMov = true

var follow = Vector2.ZERO

const idle = 1.0

export var move_to = Vector2.RIGHT * 50
export var speed = 7.0

func _ready():
	_start_tween()

func _start_tween():
	var duration = move_to.length() / float(speed * 5)
	if horizontalMov:
		tween.interpolate_property(
			self, 'follow', Vector2.ZERO, move_to, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, idle
		)
		tween.interpolate_property(
			self, 'follow', move_to, Vector2.ZERO, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, duration + idle * 2 
		)
	else:
		print('vertical movement')
		move_to = Vector2.ZERO
		
	tween.start()

func _physics_process(_delta):
	platform.position = platform.position.linear_interpolate(follow, 0.075)
