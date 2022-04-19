extends Node

export var pokedex_number = 0
export var pokedex_entry = ""
export var game_locations = []

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
