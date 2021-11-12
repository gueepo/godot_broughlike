extends "res://Scenes/Monster_Base.gd"

func StartMonster():
	print("initializing jester")
	InitializeMonster(2)

func TakeTurn():
	var tile = GetMyTile()
	var adjacentTiles = _mainSceneReference.GetPassableAdjacentNeighborsFromTile(tile)
	adjacentTiles.shuffle()
	MoveTo(adjacentTiles[0].position)
