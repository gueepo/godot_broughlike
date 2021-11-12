extends Node2D

var MAX_HP = 6

onready var _mainSceneReference = get_node("/root/MainScene")
var amount_to_move
onready var _animatedSprite = $AnimatedSprite
var _hp = 0
var _is_player = false
var _attacked_this_turn = false
var _is_stunned = false

onready var hpSprites = [$HP/HP_1, $HP/HP_2, $HP/HP_3, $HP/HP_4, $HP/HP_5, $HP/HP_6]

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
	if(_is_stunned):
		_is_stunned = false
		return
		
	_attacked_this_turn = false
	TakeTurn()
	
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

func MoveTo(position):
	# 1. check to see if we will engage in combat
	if _mainSceneReference.IsThereAMonsterAt(position):
		_attacked_this_turn = true
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
	UpdateHealth()
	
func DealDamage(damage):
	_hp -= damage
	UpdateHealth()
	
func Heal(healAmount):
	if(_hp + healAmount > MAX_HP):
		_hp = MAX_HP
	else:
		_hp += healAmount
	UpdateHealth()
	
func UpdateHealth():
	for i in range(_hp):
		hpSprites[i].visible = true
		
	for i in range(_hp, MAX_HP):
		hpSprites[i].visible = false
