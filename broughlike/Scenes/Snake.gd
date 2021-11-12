extends "res://Scenes/Monster_Base.gd"

func StartMonster():
	print("initializing snake")
	InitializeMonster(1)

func TakeTurn():
	.TakeTurn()
	
	if(!_attacked_this_turn):
		.TakeTurn()
