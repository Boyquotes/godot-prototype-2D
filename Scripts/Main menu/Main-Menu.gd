extends Control

func _on_PlayButton_pressed():
	#transition
	get_tree().change_scene("res://Levels/Main.tscn")

func _on_OptionButton_pressed():
	pass # Replace with function body.

func _on_QuitButton_pressed():
	get_tree().quit()
