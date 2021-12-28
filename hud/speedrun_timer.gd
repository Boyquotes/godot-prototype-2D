extends Label

var start_time = 0
var running = false

func _ready():
	Start()
	print(Global.player_dead)

func _process(_delta):
	if !Global.player_dead:
		get_time()

func get_time():
	var time_now = OS.get_unix_time()
	var elapsed = time_now - start_time
	var seconds = elapsed % 60
	var hours = elapsed / 3600
	var minutes = (elapsed -(3600*hours)) / 60
	var time_elapsed = "%02d:%02d" % [minutes, seconds]
	self.text = time_elapsed

func Start():
	if !Global.player_dead:
		running = true
		start_time = OS.get_unix_time()
