extends Node

var TILES_ON_HORIZONTAL = 9
var TILES_ON_VERTICAL = 9
var TILE_SIZE = 16
var map = Array()
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
	_playerReference.MoveTo(GetARandomPassableTile().position)

func CreateMapArray():
	map.resize(TILES_ON_VERTICAL)
	for i in range(TILES_ON_VERTICAL):
		map[i] = Array()
		map[i].resize(TILES_ON_HORIZONTAL)

func GenerateMap():
	for i in range(TILES_ON_VERTICAL):
		for j in range(TILES_ON_HORIZONTAL):
			var tile = tileObject.instance()
			
			var myRandom = rng.randf_range(0.0, 1.0)
			if myRandom < 0.3 or not IsInBounds(j, i):
				tile.is_passable = false
			
			add_child(tile)
			tile.position = Vector2(j * TILE_SIZE, i * TILE_SIZE)
			map[i][j] = tile
	
func is_valid_position(position):
	return !(position.x < 0 || position.x >= (TILES_ON_HORIZONTAL * TILE_SIZE) || position.y < 0 || position.y >= (TILES_ON_VERTICAL * TILE_SIZE))
	

# ===================================================================================================
# ===================================================================================================
# AUXILIARY FUNCTIONS
# ===================================================================================================
# ===================================================================================================
func IsInBounds(x, y):
	return x > 0 && y > 0 && x < TILES_ON_HORIZONTAL - 1 && y < TILES_ON_VERTICAL - 1
	
func GetARandomPassableTile():
	var tile
	for i in range(100):
		var x = rng.randi_range(0, TILES_ON_HORIZONTAL - 1)
		var y = rng.randi_range(0, TILES_ON_VERTICAL - 1)
		tile = map[x][y]
		if(tile.is_passable):
			return tile
	print("[GetARandomPassableTile] timeout!")
