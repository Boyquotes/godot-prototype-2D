extends Node2D

func _ready():
	#mudar a variavel do singleton, porque a função ready do singleton inicia mais tarde.
	Global.player = get_node("Player")
#	print(Global.player)
