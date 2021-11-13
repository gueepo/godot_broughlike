extends "res://Scenes/Monster_Base.gd"

func StartMonster():
	InitializeMonster(3)

func TakeTurn():
	var startStunned = _is_stunned
	.TakeTurn()
	if(!startStunned):
		_is_stunned = true
