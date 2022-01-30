enum {
	WOOP = 0, # move the monster to a random valid position
	DIG = 1, # destroy all walls on map, heals 2 hp
	MAELSTROM = 2, # moves all enemies to random valid positions, reset portal counter
	EXPLO = 3, # causes an explosion with the radius of 3
	
	MAX = 4 # used when generating random spells
}
