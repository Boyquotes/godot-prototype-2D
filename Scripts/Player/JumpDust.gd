extends Position2D


func _ready():
	$animation.play("dust")


func _on_animation_animation_finished(anim_name):
	queue_free()
