extends Node

var TILES_ON_HORIZONTAL = 9
var TILES_ON_VERTICAL = 9
var TILE_SIZE = 16
var map = Array()
var passableTiles = 0
var rng = RandomNumberGenerator.new()
var NUMBER_OF_TREASURE = 2

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

# music/audio
onready var _sfxPlayer = $SoundEffects
var gameoverSfx = load("res://assets/audio/gameover.wav")
var hit1Sfx = load("res://assets/audio/hit1.wav")
var hit2Sfx = load("res://assets/audio/hit2.wav")
var newLevelSfx = load("res://assets/audio/newLevel.wav")
var spellSfx = load("res://assets/audio/spell.wav")
var treasureSfx = load("res://assets/audio/treasure.wav")

# UI-related
onready var LevelLabel = $UI/LevelLabel
onready var ScoreLabel = $UI/ScoreLabel 
onready var SpellLabel = $UI/Spells
const SPELLS = preload("res://Scripts/SpellEnum.gd")

# saving
onready var SaveFile = $SaveFile

# ===============================================
# gameplay related variables
var level = 1
var _playerScore = 0
var _spawnCounter = 0
var _spawnRate = 0
var numMonsters = 0
var monsterBag = [birdMonsterObject, tankMonsterObject, eaterMonsterObject, jesterMonsterObject]
var monstersOnScene = Array()

# screen shake
var _shakeAmount = 0

func _ready():
	rng.randomize()
	CreateMapArray()
	StartLevel(3)
	SaveFile.Load()
	
	print("MainScene node is ready!")
	
	# connecting nodes
	_playerReference.connect("on_monster_used_spell", self, "UpdateUserInterface")
	_playerReference.connect("on_monster_attacked", self, "HandleCombat")
	_playerReference.connect("on_player_finished_turn", self, "UpdateAllMonsters")
	_playerReference.connect("on_player_finished_turn", self, "CheckIfPlayerGotTreasure")
	
func _process(delta):
	TickScreenshake()
	pass

func StartLevel(playerHp):
	_playerReference.SetHp(playerHp)
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
	UpdateUserInterface()
 
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
		SaveFile.AddData(_playerScore, true)
		get_tree().change_scene("res://Scenes/YouWon.tscn")
	
	for i in range(monstersOnScene.size()):
		monstersOnScene[i].queue_free()
	monstersOnScene.clear()
	CleanMap()
	
	StartLevel(3 + (level - 1))
	
	_sfxPlayer.stream = newLevelSfx
	_sfxPlayer.play()

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
	var allPassableTiles = Array()
	var Neighbors = GetAdjacentNeighbors(x, y)

	for tile in Neighbors:
		if tile.is_passable:
			allPassableTiles.append(tile)
	
	return allPassableTiles
	
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
	
	spawnedMonster.connect("on_monster_attacked", self, "HandleCombat")
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

func CheckIfPlayerGotTreasure():
	var currentTile = GetTileMonsterIsAt(_playerReference)

	if(currentTile._hasTreasure == true):
		_sfxPlayer.stream = treasureSfx
		_sfxPlayer.play()
		_playerScore += 1
		
		# checking to see if we should add spell
		if _playerScore % 3 == 0:
			var randomSpell = rng.randi_range(0, SPELLS.MAX - 1)
			_playerReference.AddSpell(randomSpell)
			_sfxPlayer.stream = spellSfx
			_sfxPlayer.play()
		
		currentTile._hasTreasure = false
		UpdateUserInterface()

# destroy a node monster, clean its tile and remove it from the monster array
func DestroyMonster(monster):
	var tile = GetTileMonsterIsAt(monster)
	if(tile.position != monster.position):
		print("tile position and monster position are different - ruh-roh")
	tile._monsterOnTile = null
	
	var index = monstersOnScene.find(monster)
	if index != -1:
		monstersOnScene.remove(index)
	monster.queue_free()
	
	if monster._is_player:
		_sfxPlayer.stream = gameoverSfx
		_sfxPlayer.play()
		print("#todo: GAME OVER!")
		print("score: ", _playerScore)
		SaveFile.AddData(_playerScore, false)
		
		yield(get_tree().create_timer(2.0),"timeout")
		get_tree().change_scene("res://Scenes/MainMenu.tscn")
	
func HandleCombat(monsterAttacking, combatPosition, damage):
	print("handling combat")
	var other = GetMonsterAt(combatPosition)
	
	if other == null:
		print("monster being attacked is null, is there something wrong?")
		return
	
	if(monsterAttacking == null):
		print("why the hell a null monster is attacking? criminal: ", monsterAttacking)
		return
	
	var tween = monsterAttacking.get_node("Tween")
	var StartPosition = monsterAttacking.position

	if(monsterAttacking._is_player):
		other._is_stunned = true
	
	# Making this so monsters don't attack other monsters
	if(monsterAttacking._is_player != other._is_player):
		other.DealDamage(damage)
		
		if rng.randf() < 0.5:
			_sfxPlayer.stream = hit1Sfx
		else:
			_sfxPlayer.stream = hit2Sfx
		_sfxPlayer.play()
		_shakeAmount = 10
		
		tween.interpolate_property(monsterAttacking, "position", StartPosition, combatPosition, 0.035, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(monsterAttacking, "position", combatPosition, StartPosition, 0.035, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)	
		tween.start()
		yield(tween, "tween_completed")
		monsterAttacking.position = StartPosition
		
		if(other._hp <= 0):
			DestroyMonster(other)

# let the monsters take their turns after player took their turn
func UpdateAllMonsters():
	print("updating all monsters")
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
	for _i in range(NUMBER_OF_TREASURE):
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
	for _i in range(100):
		var x = rng.randi_range(0, TILES_ON_HORIZONTAL - 1)
		var y = rng.randi_range(0, TILES_ON_VERTICAL - 1)
		tile = map[y][x]
		if(tile.is_passable && tile._monsterOnTile == null):
			return tile
	
func ManhattanDistance(p1, p2):
	return abs(p1.x - p2.x) + abs(p1.y - p2.y)
	
func PlaySound(sound):
	_sfxPlayer.stop()
	_sfxPlayer.stream = sound
	_sfxPlayer.play()

# ===================================================================================================
# ===================================================================================================
# SCREEN SHAKE
# ===================================================================================================
# ===================================================================================================
func TickScreenshake():
	if _shakeAmount <= 0:
		self.position = Vector2(0.0, 0.0)
		return
	
	_shakeAmount -= 1
	var shakeAngle = rng.randf() * PI * 2
	var _shakeX = (cos(shakeAngle) * _shakeAmount) / 4;
	var _shakeY = (sin(shakeAngle) * _shakeAmount) / 4;
	
	self.position = Vector2(_shakeX, _shakeY)

# ===================================================================================================
# ===================================================================================================
# USER INTERFACE
# ===================================================================================================
# ===================================================================================================
# This is kind of bad
# But there's no easy way to access enums from other files? That's kind of annoying
func SpellToString(spell):
	match spell:
		SPELLS.WOOP:
			return "WOOP"
		SPELLS.DIG:
			return "DIG"
		SPELLS.MAELSTROM:
			return "MAELSTROM"
		SPELLS.EXPLO:
			return "EXPLO"
		_:
			return "EMPTY"

func UpdateUserInterface():
	LevelLabel.text = "Level: " + str(level)
	ScoreLabel.text = "Score: " + str(_playerScore)
	
	# Updating Spells
	var spellBag = _playerReference._spellBag
	SpellLabel.text = ""
	
	if spellBag.size() > 0:
		for i in spellBag.size():
			SpellLabel.text += str(i) + ": " + SpellToString(spellBag[i]) + "\n"
	
