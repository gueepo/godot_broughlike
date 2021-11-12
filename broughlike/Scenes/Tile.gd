extends Node2D

var is_passable = true
var _internal_x = 0
var _internal_y = 0
var _monsterOnTile = null
onready var SpriteReference = $Sprite

func _ready():
	SpriteReference.region_enabled = true
	UpdatePassable(is_passable)
	
func UpdatePassable(value):
	is_passable = value
	var rect_x_position = 32 if is_passable else 48
	SpriteReference.region_rect = Rect2(Vector2(rect_x_position, 0), Vector2(16, 16))
