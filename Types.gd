extends Node

# TODO: Oof, this is gonna be an ugly table!
func get_effectiveness(attack_type: int, defender_type: int) -> float:
	match defender_type:
		PokemonData.Type.WATER:
			match attack_type:
				PokemonData.Type.GRASS:
					return 2.0
	return 1.0
