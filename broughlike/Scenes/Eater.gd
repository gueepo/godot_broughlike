extends "res://Scenes/Monster_Base.gd"

func StartMonster():
	print("initializing eater")
	InitializeMonster(1)

func TakeTurn():
	var myTile = GetMyTile()
	var neighborWalls = _mainSceneReference.GetAdjacentWalls(myTile)
	
	if neighborWalls.size() > 0:
		var wall = neighborWalls[0]
		wall.Eat()
		Heal(1)
	else:
		.TakeTurn()
