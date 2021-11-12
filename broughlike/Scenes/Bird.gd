extends "res://Scenes/Monster_Base.gd"

func StartMonster():
	print("initializing bird")
	InitializeMonster(1)

func TakeTurn():
	var myTile = GetMyTile()
	var playerTile = _mainSceneReference.GetPlayerTile()
	var adjacentTiles = _mainSceneReference.GetPassableAdjacentNeighborsFromTile(myTile)
	if(adjacentTiles.size() == 0):
		return
	
	# print("bird: mytile ", myTile, " - playerTile: ", playerTile, " - adjacent tiles: ", adjacentTiles)
	
	# go over adjacent tiles and move to the closest towards the player
	var distance = _mainSceneReference.ManhattanDistance(playerTile.position, adjacentTiles[0].position)
	var positionToMove = adjacentTiles[0].position
	for i in range(1, adjacentTiles.size()):
		var newDistance = _mainSceneReference.ManhattanDistance(playerTile.position, adjacentTiles[i].position)
		if(newDistance < distance):
			distance = newDistance
			positionToMove = adjacentTiles[i].position
	
	MoveTo(positionToMove)
	
