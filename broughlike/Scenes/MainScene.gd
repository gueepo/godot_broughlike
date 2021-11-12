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
var _spawnCounter = 0
var _spawnRate = 0
var numMonsters = 0
var monsterBag = [birdMonsterObject, snakeMonsterObject, tankMonsterObject, eaterMonsterObject, jesterMonsterObject]
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
	
	print("attempts: ", attempts)
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
			
func CleanMap():
	for i in range(TILES_ON_VERTICAL):
		for j in range(TILES_ON_HORIZONTAL):
			map[i][j].queue_free()

# This is called when the player steps on the exit portal
func LevelUp():
	level += 1
	if(level >= 6):
		print("YOU WON!")
	
	
	print("level up")
	for i in range(monstersOnScene.size()):
		monstersOnScene[i].queue_free()
	monstersOnScene.clear()
	CleanMap()
	
	StartLevel(3 + (level - 1))

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
	
func GetAdjacentWalls(tile):
	var walls = Array()
	var neighbors = GetAdjacentNeighbors(tile._internal_x, tile._internal_y)
	
	for tile in neighbors:
		if !tile.is_passable:
			walls.append(tile)
			
	return walls
	
func GetPassableAdjacentNeighborsFromTile(tile):
	return GetPassableAdjacentNeighbors(tile._internal_x, tile._internal_y)

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
	
func SpawnMonster():
	var monster = monsterBag[rng.randi_range(0, monsterBag.size() - 1)]
	var spawnedMonster = monster.instance()
	add_child(spawnedMonster)
	monstersOnScene.append(spawnedMonster)
	var MonsterPosition = GetARandomPassableTile().position
	while IsThereAMonsterAt(MonsterPosition):
		MonsterPosition = GetARandomPassableTile().position
	
	spawnedMonster.MoveTo(MonsterPosition)
	
func GetTileMonsterIsAt(monster):
	return GetTileFromWorldPosition(monster.position)
	
func GetMonsterAt(position):
	var t = GetTileFromWorldPosition(position)
	return t._monsterOnTile
	
func GetPlayerTile():
	return GetTileFromWorldPosition(_playerReference.position)
	
func IsThereAMonsterAt(position):
	var t = GetTileFromWorldPosition(position)
	return t._monsterOnTile != null
	
func MonsterMovedTo(monster, oldPosition, newPosition):
	var oldTile = GetTileFromWorldPosition(oldPosition)
	var newTile = GetTileFromWorldPosition(newPosition)
	oldTile._monsterOnTile = null
	newTile._monsterOnTile = monster
	
	if(monster._is_player):
		UpdateAllMonsters()
		
func DestroyMonster(monster):
	if monster._is_player:
		print("#todo: GAME OVER!")
	
	var tile = GetTileMonsterIsAt(monster)
	tile._monsterOnTile = null
	
	var index = monstersOnScene.find(monster)
	if index != -1:
		monstersOnScene.remove(index)
	monster.queue_free()
	
func HandleCombat(monsterAttacking, combatPosition, damage):
	var other = GetMonsterAt(combatPosition)
	
	# avoiding so monsters attack themselves
	if(monsterAttacking._is_player != other._is_player):
		print(monsterAttacking.name, " deals ", damage, " damage on ", other.name)
		other.DealDamage(1)
		if(other._hp <= 0):
			DestroyMonster(other)
	
	if(monsterAttacking._is_player):
		other._is_stunned = true
		UpdateAllMonsters()

#
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
	print("[GetARandomPassableTile] timeout!")
	
func ManhattanDistance(p1, p2):
	return abs(p1.x - p2.x) + abs(p1.y - p2.y)
