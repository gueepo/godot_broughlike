extends "res://Scripts/Monster_Base.gd"

func StartMonster():
	InitializeMonster(1)

func TakeTurn():
	.TakeTurn()
	
	# THIS IS NOT WORKING
	# This stopped working when I introduced moving and attacking with tweening.
	# Why this broke?
	# we have to sort of stop the game to tween, instead of tweening and moving on
	# OR we have to process all turns separately and then playing the tween at the end of the turn
	
	var t = $Tween
	yield(t, "tween_completed")
	
	print("snake is taking its second turn, attacked this turn: ", _attacked_this_turn)
	print("position: ", self.position, " actual position: ", _actual_position_x, " ", _actual_position_y )
	
	if(!_attacked_this_turn):
		.TakeTurn()
