extends Node2D

export var pokedex_number = 0
export var pokedex_entry = ""
export var game_locations = []

export(int, 0, 100) var base_hp = 0
export(int, 0, 100) var base_attack = 0
export(int, 0, 100) var base_defence = 0
export(int, 0, 100) var base_special_attack = 0
export(int, 0, 100) var base_special_defence = 0
export(int, 0, 100) var base_speed = 0

export var learnset = []
export(PoolIntArray) var learnable_tms = []
export(PoolIntArray) var learnable_hms = []

export var evolutions = []
