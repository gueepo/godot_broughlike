extends "res://Scenes/Monster_Base.gd"

func StartMonster():
	InitializeMonster(1)

func TakeTurn():
	.TakeTurn()
	
	if(!_attacked_this_turn):
		.TakeTurn()
