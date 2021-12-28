extends CanvasLayer

func _process(_delta):
	$FPS/HBoxContainer/VBoxContainer/FPS.text = 'FPS: ' + str(Performance.get_monitor(Performance.TIME_FPS))
	$Coin/Label.text = str(Global.coins)
