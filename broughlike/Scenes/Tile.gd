extends Node2D

var is_passable = true
var _internal_x = 0
var _internal_y = 0
var _monsterOnTile = null
var _hasTreasure = false setget SetTreasure
onready var SpriteReference = $Sprite
onready var Treasure = $Treasure

func _ready():
	SpriteReference.region_enabled = true
	UpdatePassable(is_passable)
	UpdateTreasure()
	
func UpdatePassable(value):
	is_passable = value
	var rect_x_position = 32 if is_passable else 48
	SpriteReference.region_rect = Rect2(Vector2(rect_x_position, 0), Vector2(16, 16))

func UpdateTreasure():
	if _hasTreasure:
		Treasure.visible = true
	else:
		Treasure.visible = false

func Eat():
	UpdatePassable(true)
	
func SetTreasure(value):
	_hasTreasure = value
	UpdateTreasure()
