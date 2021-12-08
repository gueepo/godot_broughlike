extends Node

enum SPELLS {
	WOOP = 0, # move the monster to a random valid position
	DIG = 1, # destroy all walls on map, heals 2 hp
	
	MAX = 2 # used when generating random spells
}

func UseSpell(spell):
	match spell:
		SPELLS.WOOP:
			CastWoop()
		SPELLS.DIG:
			CastDig()
		_:
			print("spell not implemented")

func CastWoop():
	print("cast woop")
	pass

func CastDig():
	print("cast dig")
	pass