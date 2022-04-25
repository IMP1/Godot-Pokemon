extends Resource
class_name Move

enum Category {
	NONE,
	PHYSICAL,
	SPECIAL,
	STATUS
}

export var move_name = ""
export(PokemonData.Type) var type = 0
export(Category) var category = 0
export(bool) var contact = false
export var starting_pp = 0
export var max_pp = 0
export var power = 0
export var accuracy = 0

export(bool) var affected_by_protect = false
export(bool) var affected_by_magic_coat = false
export(bool) var affected_by_snatch = false
export(bool) var affected_by_mirror_move = false
export(bool) var affected_by_kings_rock = false

# Possible Targets

# Contest Data

