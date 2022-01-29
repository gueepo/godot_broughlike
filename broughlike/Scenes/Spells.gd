extends Node

onready var _mainSceneReference = get_node("/root/MainScene")
onready var _parentMonster = get_parent()
var usedSpellSfx = load("res://assets/audio/spell.wav")
const SPELLS = preload("res://Scenes/SpellEnum.gd")



func UseSpell(spell):
	match spell:
		SPELLS.WOOP:
			CastWoop()
		SPELLS.DIG:
			CastDig()
		_:
			print("spell not implemented")

# -------------------------------------------
# WOOP: Move this monster to a random valid position
#
# -------------------------------------------
func CastWoop():
	var newTile = _mainSceneReference.GetARandomPassableTile()
	_parentMonster.MoveToTile(newTile)
	_mainSceneReference.PlaySound(usedSpellSfx)

# -------------------------------------------
# DIG: Destroy all walls on map, heals 2 HP.
#
# -------------------------------------------
func CastDig():
	
	# removing all walls from the map!
	for i in range(_mainSceneReference.TILES_ON_HORIZONTAL):
		for j in range(_mainSceneReference.TILES_ON_VERTICAL):
			if(not _mainSceneReference.map[i][j].is_passable and _mainSceneReference.IsInBounds(i, j)):
				_mainSceneReference.map[i][j].Eat()
	
	# recovering 2 HP
	_parentMonster.Heal(2)
	
	_mainSceneReference.PlaySound(usedSpellSfx)
