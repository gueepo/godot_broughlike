extends Node2D

onready var _mainSceneReference = get_node("/root/MainScene")
var amount_to_move
onready var _animatedSprite = $AnimatedSprite
var _hp = 0
var _is_player = false

func _ready():
	amount_to_move = _mainSceneReference.TILE_SIZE
	_animatedSprite.z_index = 5
	_animatedSprite.position = Vector2(8, 8)
	_animatedSprite.playing = true
	StartMonster()
	
func GetMyTile():
	return _mainSceneReference.GetTileMonsterIsAt(self)
	
func StartMonster():
	pass
	
func Update():
	TakeTurn()
	pass
	
func TakeTurn():
	pass

func MoveTo(position):
	# 1. check to see if we will engage in combat
	if _mainSceneReference.IsThereAMonsterAt(position):
		_mainSceneReference.HandleCombat(self, position, 1)
		return
	# check if new position is valid
	# #todo: engage in combat will happen here
	# if position is valid, is passable, and there is no combat, we just move
	if(_mainSceneReference.is_valid_position(position)):
		var oldPosition = self.position
		self.position = position
		_mainSceneReference.MonsterMovedTo(self, oldPosition, position)

func InitializeMonster(hp):
	_hp = hp
