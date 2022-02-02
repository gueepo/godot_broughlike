extends Node2D

# constants
var MAX_HP = 6
var MAX_SPELLS = 6

# object references
onready var _mainSceneReference = get_node("/root/MainScene")
onready var _animatedSprite = $AnimatedSprite
onready var _portalSprite = $Portal
onready var hpSprites = [$HP/HP_1, $HP/HP_2, $HP/HP_3, $HP/HP_4, $HP/HP_5, $HP/HP_6]
onready var _spellsRef = $Spells
var _spellBag = Array()

# internal variables
var _hp = 0
var _is_player = false
var _attacked_this_turn = false
var _is_stunned = false
var _teleportCounter = 2
var _amount_to_move

var _actual_position_x = 0
var _actual_position_y = 0

# Monster Signals
# signal on_monster_moved
signal on_monster_attacked(monster_attacking, combat_position, damage)
signal on_monster_hp_changed(old_hp, new_hp)
signal on_monster_used_spell


func _ready():
	# connecting signals
	self.connect("on_monster_hp_changed", self, "UpdateHealth")
	
	_amount_to_move = _mainSceneReference.TILE_SIZE
	_animatedSprite.z_index = 5
	_animatedSprite.position = Vector2(8, 8)
	_animatedSprite.playing = true
	_portalSprite.z_index = 10
	_portalSprite.position = Vector2(8, 8)
	_portalSprite.playing = true
	StartMonster()
	UpdatePortalVisibility()
	

func InitializeMonster(hp):
	SetHp(hp)
	
func GetMyTile():
	return _mainSceneReference.GetTileMonsterIsAt(self)

# this is to be overrided by children
func StartMonster():
	pass

func Update():
	if(_is_stunned || _teleportCounter > 0):
		_teleportCounter -= 1
		_is_stunned = false
		UpdatePortalVisibility()
		return
		
	_attacked_this_turn = false
	TakeTurn()
	
func UpdatePortalVisibility():
	if(_teleportCounter > 0):
		_portalSprite.visible = true
		_animatedSprite.visible = false
	else:
		_portalSprite.visible = false
		_animatedSprite.visible = true
	
func TakeTurn():
	var myTile = GetMyTile()
	var playerTile = _mainSceneReference.GetPlayerTile()
	var adjacentTiles = _mainSceneReference.GetPassableAdjacentNeighborsFromTile(myTile)
	if(adjacentTiles.size() == 0):
		return

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
		emit_signal("on_monster_attacked", self, position, 1)
		return
		
	# check if new position is valid
	# if position is valid, is passable, and there is no combat, we just move
	if(_mainSceneReference.is_valid_position(position)):
		var tween = get_node("Tween")
		var oldPosition = self.position
		_mainSceneReference.MonsterMovedTo(self, oldPosition, position)
		
		_actual_position_x = position.x
		_actual_position_y = position.y
		
		tween.interpolate_property(self, "position", oldPosition, position, 0.075, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween, "tween_completed")
		
		# check if it is portal
		if(self._is_player):
			if (_mainSceneReference._exitPortal.position == position):
				_mainSceneReference.LevelUp();
				return
				
func MoveToTile(tile):
	MoveTo(tile.position)

# #########################
# HP MANAGEMENT
# #########################
func SetHp(hp):
	_hp = min(hp, MAX_HP)
	emit_signal("on_monster_hp_changed", hp, hp)
	
func DealDamage(damage):
	var old_hp = _hp
	_hp -= damage
	emit_signal("on_monster_hp_changed", old_hp, _hp)
	
func Heal(healAmount):
	var old_hp = _hp
	SetHp(_hp + healAmount)
	emit_signal("on_monster_hp_changed", old_hp, _hp)

func UpdateHealth(_old_hp, _new_hp):
	for i in range(_hp):
		hpSprites[i].visible = true
		
	for i in range(_hp, MAX_HP):
		hpSprites[i].visible = false

# #########################
# SPELL MANAGEMENT
# #########################
func UseSpell(index):
	if index < 0 || index >= _spellBag.size():
		print("unable to cast spell: " + str(index))
		return
	
	_spellsRef.UseSpell(_spellBag[index])
	_spellBag.remove(index)
	emit_signal("on_monster_used_spell")

func AddSpell(spell):
	if(_spellBag.size() > MAX_SPELLS):
		return
	
	_spellBag.append(spell)
