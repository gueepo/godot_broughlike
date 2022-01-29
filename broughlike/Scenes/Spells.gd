extends Node

onready var _mainSceneReference = get_node("/root/MainScene")
onready var _parentMonster = get_parent()
var usedSpellSfx = load("res://assets/audio/spell.wav")
const SPELLS = preload("res://Scenes/SpellEnum.gd")



func UseSpell(spell):
	
	_mainSceneReference.PlaySound(usedSpellSfx)
	
	match spell:
		SPELLS.WOOP:
			CastWoop()
		SPELLS.DIG:
			CastDig()
		SPELLS.MAELSTROM:
			CastMaelstrom()
		_:
			print("spell not implemented")

# -------------------------------------------
# WOOP: Move this monster to a random valid position
#
# -------------------------------------------
func CastWoop():
	var newTile = _mainSceneReference.GetARandomPassableTile()
	_parentMonster.MoveToTile(newTile)

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

# -------------------------------------------
# MAELSTROM: moves all enemies to random valid positions, reset portal counter
#
# -------------------------------------------
func CastMaelstrom():
	print("casting maelstrom!")
	# 1. get all monsters
	var allMonsters = _mainSceneReference.monstersOnScene
	# 2. move to valid position and reset portal counter
	for m in _mainSceneReference.monstersOnScene:
		print("monster: ", m.name)
		m._is_stunned = true
		m._teleportCounter = 2
		var newTile = _mainSceneReference.GetARandomPassableTile()
		m.MoveToTile(newTile)
		m.UpdatePortalVisibility()
		
