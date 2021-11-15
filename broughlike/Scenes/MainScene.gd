extends Node

var TILES_ON_HORIZONTAL = 9
var TILES_ON_VERTICAL = 9
var TILE_SIZE = 16
var map = Array()
var passableTiles = 0
var rng = RandomNumberGenerator.new()
var NUMBER_OF_TREASURE = 2

# what is the main scene going to do?
# 1. generate the map

# loading tile scene "object"
var tileObject = load("res://Scenes/Tile.tscn")
var treasureObject = load("res://Scenes/Treasure.tscn")

var birdMonsterObject = load("res://Scenes/Bird.tscn")
var snakeMonsterObject = load("res://Scenes/Snake.tscn")
var tankMonsterObject = load("res://Scenes/Tank.tscn")
var eaterMonsterObject = load("res://Scenes/Eater.tscn")
var jesterMonsterObject = load("res://Scenes/Jester.tscn")
onready var _playerReference = $Player
onready var _exitPortal = $ExitPortal

# ===============================================
# gameplay related variables
var level = 1
var _playerScore = 0
var _spawnCounter = 0
var _spawnRate = 0
var numMonsters = 0
# var monsterBag = [birdMonsterObject, snakeMonsterObject, tankMonsterObject, eaterMonsterObject, jesterMonsterObject]
var monsterBag = [snakeMonsterObject]
var monstersOnScene = Array()

func _ready():
	rng.randomize()
	CreateMapArray()
	StartLevel(3)

func StartLevel(playerHp):
	_playerReference.SetHp(playerHp)
	_playerReference.UpdateHealth()
	_spawnRate = 15
	_spawnCounter = _spawnRate
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
	
	print("map generation attempts: ", attempts)
	if attempts == 100:
		print("timed out!")
	
	var PlayerPosition = GetARandomPassableTile().position
	var ExitPortalPosition = GetARandomPassableTile().position
	while ExitPortalPosition == PlayerPosition:
		ExitPortalPosition = GetARandomPassableTile().position
	 
	_playerReference.MoveTo(PlayerPosition)
	_exitPortal.position = ExitPortalPosition
	# todo: generate monsters
	GenerateMonsters()
	GenerateTreasures()
 
# correctly create and resize the arrays for the map
func CreateMapArray():
	map.resize(TILES_ON_VERTICAL)
	for i in range(TILES_ON_VERTICAL):
		map[i] = Array()
		map[i].resize(TILES_ON_HORIZONTAL)

# generate map and creates each individual node
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

# deletes all tile nodes
func CleanMap():
	for i in range(TILES_ON_VERTICAL):
		for j in range(TILES_ON_HORIZONTAL):
			map[i][j].queue_free()

# This is called when the player steps on the exit portal
func LevelUp():
	level += 1
	if(level >= 6):
		print("YOU WON!")
	
	for i in range(monstersOnScene.size()):
		monstersOnScene[i].queue_free()
	monstersOnScene.clear()
	CleanMap()
	
	StartLevel(3 + (level - 1))

# ===================================================================================================
# ===================================================================================================
# MAP RELATED FUNCTIONS
# ===================================================================================================
# ===================================================================================================
# returns the neighbor tile from the given position in the given direction
func GetTileNeighbor(x, y, dx, dy):
	if IsInBounds(x + dx, y + dy):
		return map[y+dy][x+dx]
	return null

# gets all adjacent neighbors of the tile on the given position
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
	
func GetAdjacentWalls(tile):
	var walls = Array()
	var neighbors = GetAdjacentNeighbors(tile._internal_x, tile._internal_y)
	
	for tile in neighbors:
		if !tile.is_passable:
			walls.append(tile)
			
	return walls
	
func GetPassableAdjacentNeighborsFromTile(tile):
	return GetPassableAdjacentNeighbors(tile._internal_x, tile._internal_y)

# use a flood-fill approach to try to connect all tiles
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
# MONSTERS
# ===================================================================================================
# ===================================================================================================
func GenerateMonsters():
	numMonsters = level + 1
	for i in numMonsters:
		SpawnMonster()

# spawn a monster on a random passable tile
func SpawnMonster():
	var monster = monsterBag[rng.randi_range(0, monsterBag.size() - 1)]
	var spawnedMonster = monster.instance()
	add_child(spawnedMonster)
	monstersOnScene.append(spawnedMonster)
	var MonsterPosition = GetARandomPassableTile().position
	while IsThereAMonsterAt(MonsterPosition):
		MonsterPosition = GetARandomPassableTile().position
	
	spawnedMonster.MoveTo(MonsterPosition)

# THIS FUNCTION IS WRONG!
# because when we add tween "monster.position" is not always the true position
func GetTileMonsterIsAt(monster):
	return GetTileFromWorldPosition(Vector2(monster._actual_position_x, monster._actual_position_y))

func GetMonsterAt(position):
	var t = GetTileFromWorldPosition(position)
	return t._monsterOnTile

func GetPlayerTile():
	return GetTileFromWorldPosition(Vector2(_playerReference._actual_position_x, _playerReference._actual_position_y))
	
func IsThereAMonsterAt(position):
	var t = GetTileFromWorldPosition(position)
	return t._monsterOnTile != null
	
# update tiles when a monster moves from/to somewhere
func MonsterMovedTo(monster, oldPosition, newPosition):
	var oldTile = GetTileFromWorldPosition(oldPosition)
	var newTile = GetTileFromWorldPosition(newPosition)
	oldTile._monsterOnTile = null
	newTile._monsterOnTile = monster
	
	if(monster._is_player):
		UpdateAllMonsters()
		
		# get treasure
		if(newTile._hasTreasure == true):
			# todo:audio
			_playerScore += 1
			newTile._hasTreasure = false

# destroy a node monster, clean its tile and remove it from the monster array
func DestroyMonster(monster):
	if monster._is_player:
		print("#todo: GAME OVER!")
		print("score: ", _playerScore)
	
	var tile = GetTileMonsterIsAt(monster)
	if(tile.position != monster.position):
		print("tile position and monster position are different - ruh-roh")
	tile._monsterOnTile = null
	
	var index = monstersOnScene.find(monster)
	if index != -1:
		monstersOnScene.remove(index)
	monster.queue_free()
	
func HandleCombat(monsterAttacking, combatPosition, damage):
	var other = GetMonsterAt(combatPosition)
	
	if(other == null):
		print("monster being attacked is null, is there something wrong?")
		return
	
	var tween = monsterAttacking.get_node("Tween")
	var StartPosition = monsterAttacking.position
	
	# avoiding so monsters attack themselves
	if(monsterAttacking._is_player != other._is_player):
		other.DealDamage(1)
		
		tween.interpolate_property(monsterAttacking, "position", StartPosition, combatPosition, 0.035, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(monsterAttacking, "position", combatPosition, StartPosition, 0.035, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)	
		tween.start()
		yield(tween, "tween_completed")
		monsterAttacking.position = StartPosition
		
		if(other._hp <= 0):
			DestroyMonster(other)
	
	if(monsterAttacking._is_player):
		other._is_stunned = true
		UpdateAllMonsters()

# let the monsters take their turns after player took their turn
func UpdateAllMonsters():
	for m in monstersOnScene:
		if m != null:
			m.Update()
	
	_spawnCounter -= 1
	if(_spawnCounter <= 0):
		SpawnMonster()
		_spawnCounter = _spawnRate
		_spawnRate -= 1
	

# ===================================================================================================
# ===================================================================================================
# TREASURE
# ===================================================================================================
# ===================================================================================================
func GenerateTreasures():
	for i in range(NUMBER_OF_TREASURE):
		GetARandomPassableTile()._hasTreasure = true

# ===================================================================================================
# ===================================================================================================
# AUXILIARY FUNCTIONS
# ===================================================================================================
# ===================================================================================================
func GetTileFromWorldPosition(position):
	var arrayPositionX = position.x / TILE_SIZE
	var arrayPositionY = position.y / TILE_SIZE
	var tile = map[arrayPositionY][arrayPositionX]
	return tile
	
func is_valid_position(position):
	var arrayPositionX = position.x / TILE_SIZE
	var arrayPositionY = position.y / TILE_SIZE
	var tile = GetTileFromWorldPosition(position)
	return IsInBounds(arrayPositionX, arrayPositionY) && tile.is_passable && (tile._monsterOnTile == null)
	
func IsInBounds(x, y):
	return x > 0 && y > 0 && x < TILES_ON_HORIZONTAL - 1 && y < TILES_ON_VERTICAL - 1
	
func GetARandomPassableTile():
	var tile
	for i in range(100):
		var x = rng.randi_range(0, TILES_ON_HORIZONTAL - 1)
		var y = rng.randi_range(0, TILES_ON_VERTICAL - 1)
		tile = map[y][x]
		if(tile.is_passable && tile._monsterOnTile == null):
			return tile
	
func ManhattanDistance(p1, p2):
	return abs(p1.x - p2.x) + abs(p1.y - p2.y)
