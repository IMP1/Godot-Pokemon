extends Node

export(PackedScene) var base_pokemon_data

var base_pokemon

var nickname: String

var nature: int
var individual_values # https://bulbapedia.bulbagarden.net/wiki/Individual_values#Generation_III_onward
var effort_values # https://bulbapedia.bulbagarden.net/wiki/Effort_values
var personality_values

var level: int = 1
var hp: int = 0
var attack: int = 0
var defence: int = 0
var special_attack: int = 0
var special_defence: int = 0
var speed: int = 0

var moves: Array = [
#	{
#		"base_move": null,
#		"pp": 0,
#		"max_pp": 0,
#	},
]

func _ready():
	base_pokemon = base_pokemon_data.instance()
