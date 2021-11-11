extends Node

var TILES_ON_HORIZONTAL = 9
var TILES_ON_VERTICAL = 9
var TILE_SIZE = 16
var map = Array()
var passableTiles = 0
var rng = RandomNumberGenerator.new()

# what is the main scene going to do?
# 1. generate the map

# loading tile scene "object"
var tileObject = load("res://Scenes/Tile.tscn")
onready var _playerReference = $Player

func _ready():
	rng.randomize()
	CreateMapArray()
	GenerateMap()
	
	# validate generated map
	var attempts = 0
	for i in (100):
		attempts += 1
		var connectedTiles = GetConnectedTiles()
		if connectedTiles.size() == passableTiles:
			break;
		else:
			GenerateMap()
	
	print("attempts: ", attempts)
	if attempts == 100:
		print("timed out!")
		
	_playerReference.MoveTo(GetARandomPassableTile().position)

func CreateMapArray():
	map.resize(TILES_ON_VERTICAL)
	for i in range(TILES_ON_VERTICAL):
		map[i] = Array()
		map[i].resize(TILES_ON_HORIZONTAL)

func GenerateMap():
	passableTiles = 0
	for i in range(TILES_ON_VERTICAL):
		for j in range(TILES_ON_HORIZONTAL):
			var tile = tileObject.instance()
			
			var myRandom = rng.randf_range(0.0, 1.0)
			if myRandom < 0.3 or not IsInBounds(j, i):
				tile.is_passable = false
			tile._internal_x = j
			tile._internal_y = i
			
			passableTiles += 1 if tile.is_passable else 0
			add_child(tile)
			tile.position = Vector2(j * TILE_SIZE, i * TILE_SIZE)
			map[i][j] = tile
			
# ===================================================================================================
# ===================================================================================================
# MAP VALIDATION FUNCTIONS
# ===================================================================================================
# ===================================================================================================
func GetTileNeighbor(x, y, dx, dy):
	if IsInBounds(x + dx, y + dy):
		return map[y+dy][x+dx]
	return null
	
func GetAdjacentNeighbors(x, y):
	var adjacentTiles = Array()
	var leftTile = GetTileNeighbor(x, y, -1, 0)
	var rightTile = GetTileNeighbor(x, y, 1, 0)
	var upTile = GetTileNeighbor(x, y, 0, 1)
	var downTile = GetTileNeighbor(x, y, 0, -1)
	
	if (leftTile != null):
		adjacentTiles.push_back(leftTile)
		
	if (rightTile != null):
		adjacentTiles.push_back(rightTile)
		
	if (upTile != null):
		adjacentTiles.push_back(upTile)
		
	if (downTile != null):
		adjacentTiles.push_back(downTile)
		
	return adjacentTiles
	
func GetPassableAdjacentNeighbors(x, y):
	var passableTiles = Array()
	var Neighbors = GetAdjacentNeighbors(x, y)

	for tile in Neighbors:
		if tile.is_passable:
			passableTiles.append(tile)
			
	return passableTiles

func GetConnectedTiles():
	var connectedTiles = Array()
	var frontier = Array()
	frontier.push_back(GetARandomPassableTile())
	
	while(frontier.size() > 0):
		# get next tile
		var nextTile = frontier.pop_front()
		connectedTiles.append(nextTile)
		# add all "nextTile" PASSABLE neighbors to the frontier
		var AdjacentNeighbors = GetPassableAdjacentNeighbors(nextTile._internal_x, nextTile._internal_y)
		# add all adjacent neighbors to the frontier IF THEY ARE NOT THERE AND NOT CONNECTED SO WE DON'T GET INTO AN INFINITE LOOP
		if AdjacentNeighbors.size() > 0:
			for tile in AdjacentNeighbors:
				if (!connectedTiles.has(tile) && !frontier.has(tile)):
					frontier.push_back(tile)
	
	return connectedTiles

# ===================================================================================================
# ===================================================================================================
# AUXILIARY FUNCTIONS
# ===================================================================================================
# ===================================================================================================
func is_valid_position(position):
	var arrayPositionX = position.x / TILE_SIZE
	var arrayPositionY = position.y / TILE_SIZE
	var tile = map[arrayPositionY][arrayPositionX]
	return IsInBounds(arrayPositionX, arrayPositionY) && tile.is_passable
	# return !(position.x < 0 || position.x >= (TILES_ON_HORIZONTAL * TILE_SIZE) || position.y < 0 || position.y >= (TILES_ON_VERTICAL * TILE_SIZE))
	
func IsInBounds(x, y):
	return x > 0 && y > 0 && x < TILES_ON_HORIZONTAL - 1 && y < TILES_ON_VERTICAL - 1
	
func GetARandomPassableTile():
	var tile
	for i in range(100):
		var x = rng.randi_range(0, TILES_ON_HORIZONTAL - 1)
		var y = rng.randi_range(0, TILES_ON_VERTICAL - 1)
		tile = map[y][x]
		if(tile.is_passable):
			return tile
	print("[GetARandomPassableTile] timeout!")
