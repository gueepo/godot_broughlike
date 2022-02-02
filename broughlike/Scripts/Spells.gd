extends Node

onready var _mainSceneReference = get_node("/root/MainScene")
onready var _parentMonster = get_parent()
var usedSpellSfx = load("res://assets/audio/spell.wav")
var explosionSfx = load("res://assets/audio/gameover.wav")
const SPELLS = preload("res://Scripts/SpellEnum.gd")

var explosionObject = load("res://Scenes/Explosion.tscn")



func UseSpell(spell):
	
	_mainSceneReference.PlaySound(usedSpellSfx)
	
	match spell:
		SPELLS.WOOP:
			CastWoop()
		SPELLS.DIG:
			CastDig()
		SPELLS.MAELSTROM:
			CastMaelstrom()
		SPELLS.EXPLO:
			CastExplosion()
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
		
# -------------------------------------------
# EXPLO: causes an explosion with the radius of 3
#
# -------------------------------------------
func CastExplosion():
	var t = _mainSceneReference.TILE_SIZE
	var ExplosionDirections = Array()
	
	ExplosionDirections.append(Vector2(t, 0))
	ExplosionDirections.append(Vector2(-t, 0))
	ExplosionDirections.append(Vector2(0, t))
	ExplosionDirections.append(Vector2(0, -t))
	
	ExplosionDirections.append(Vector2(t, t))
	ExplosionDirections.append(Vector2(-t, -5))
	ExplosionDirections.append(Vector2(-t, t))
	ExplosionDirections.append(Vector2(t, -t))
	
	ExplosionDirections.append(Vector2(2*t, 0))
	ExplosionDirections.append(Vector2(2*-t, 0))
	ExplosionDirections.append(Vector2(0, 2*t))
	ExplosionDirections.append(Vector2(0, 2*-t))
	
	var currentPosition = _parentMonster.position
	var currentTile = _parentMonster.GetMyTile()
	
	_mainSceneReference._shakeAmount = 50
	
	for dir in ExplosionDirections:
		_mainSceneReference.PlaySound(explosionSfx)
		var explo = explosionObject.instance()
		add_child(explo)
		explo.position = currentPosition + dir
		
		# checking for damage
		var monster = _mainSceneReference.GetMonsterAt(currentPosition+dir)
		if monster != null:
			monster.DealDamage(3)
			if monster._hp <= 0:
				_mainSceneReference.DestroyMonster(monster)
