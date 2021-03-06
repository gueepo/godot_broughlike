extends "res://Scripts/Monster_Base.gd"

func StartMonster():
	InitializeMonster(2)

func TakeTurn():
	var tile = GetMyTile()
	var adjacentTiles = _mainSceneReference.GetPassableAdjacentNeighborsFromTile(tile)
	adjacentTiles.shuffle()
	MoveTo(adjacentTiles[0].position)
