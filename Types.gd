extends Node

enum { NONE, NORMAL, WATER, FIRE, GRASS }

# TODO: Oof, this is gonna be an ugly table!
func get_effectiveness(attack_type: int, defender_type: int) -> float:
	match defender_type:
		WATER:
			match attack_type:
				GRASS:
					return 2.0
	return 1.0
