extends "res://Scenes/Monster_Base.gd"

func StartMonster():
	InitializeMonster(1)

func TakeTurn():
	.TakeTurn()
	
	# THIS IS NOT WORKING
	# This stopped working when I introduced moving and attacking with tweening.
	# Why this broke?
	# we have to sort of stop the game to tween, instead of tweening and moving on
	# OR we have to process all turns separately and then playing the tween at the end of the turn
	
	#if(!_attacked_this_turn):
	#	.TakeTurn()
