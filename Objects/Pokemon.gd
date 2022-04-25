extends Node

export(Resource) var base_data

var nickname: String

var nature: int
var individual_values # https://bulbapedia.bulbagarden.net/wiki/Individual_values#Generation_III_onward
var personality_values

var level: int = 1
var hp: int = 0
var max_hp: int = 0
var attack: int = 0
var defence: int = 0
var special_attack: int = 0
var special_defence: int = 0
var speed: int = 0
var experience: int = 0

var status_effect = null # Sleep, Poison, etc.

var moves: Array = [
#	{
#		"base_move": null,
#		"pp": 0,
#		"max_pp": 0,
#	},
]

# Battle Stats
var accuracy: float = 1.0
var evasion: float = 0.0
var attack_boost: int = 0
var defence_boost: int = 0
var special_attack_boost: int = 0
var special_defence_boost: int = 0
var speed_boost: int = 0
var critical_hit_boost: int = 0
var is_confused: bool = false
var is_charmed: bool = false 

func get_name() -> String:
	if nickname:
		return nickname
	else:
		return base_data.pokemon_name

func get_types() -> Array:
	var list = []
	if base_data.type_1 and base_data.type_1 != PokemonData.Type.NONE:
		list.append(base_data.type_1)
	if base_data.type_2 and base_data.type_2 != PokemonData.Type.NONE:
		list.append(base_data.type_2)
	return list

func reset_battle_stats():
	accuracy = 1.0
	evasion = 0.0
	attack_boost = 0
	defence_boost = 0
	special_attack_boost = 0
	special_defence_boost = 0
	speed_boost = 0
	critical_hit_boost = 0
	is_confused = false
	is_charmed = false
