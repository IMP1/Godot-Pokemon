extends Resource
class_name PokemonData

enum EggGroup { # https://bulbapedia.bulbagarden.net/wiki/Egg_Group
	MONSTER,
	HUMANSHAPE,
	WATER_1,
	WATER_3,
	BUG,
	MINERAL,
	FLYING,
	AMORPHOUS,
	FIELD,
	WATER_2,
	FAIRY,
	DITTO,
	GRASS,
	DRAGON,
	NO_EGGS_DISCOVERED,
	GENDER_UNKNOWN,
}

enum Type { # https://bulbapedia.bulbagarden.net/wiki/Type
	NONE, 
	NORMAL,
	FIGHTING,
	FLYING,
	POISON,
	GROUND,
	ROCK,
	BUG,
	GHOST,
	STEEL,
	FIRE, 
	WATER, 
	GRASS,
	ELECTRIC,
	PSYCHIC,
	ICE,
	DRAGON,
	DARK,
	FAIRY,
}

export var pokemon_name = ""
export var pokedex_number = 0
export var pokedex_entry = ""
export var weight = ""
export var height = ""
export(Type) var type_1 = 0
export(Type) var type_2 = 0

export var base_experience_yield = 0
export var ev_yield_HP = 0
export var ev_yield_attack = 0
export var ev_yield_defence = 0
export var ev_yield_special_attack = 0
export var ev_yield_special_defence = 0
export var ev_yield_speed = 0

export(EggGroup) var egg_group = 0

export(int, 0, 100) var hp = 0
export(int, 0, 100) var attack = 0
export(int, 0, 100) var defence = 0
export(int, 0, 100) var special_attack = 0
export(int, 0, 100) var special_defence = 0
export(int, 0, 100) var speed = 0

export var learnset = []
export(PoolIntArray) var learnable_tms = []
export(PoolIntArray) var learnable_hms = []

export var evolutions = []

export(Texture) var spriteBattleFront
export(Texture) var spriteBattleBack
export(Texture) var spriteMenu
export(Texture) var spriteFootprint

export var game_locations = []

# IVs
# Gender ratios
