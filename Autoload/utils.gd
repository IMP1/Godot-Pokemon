extends Node

const TILE_SIZE = 16

func get_player():
	return get_node("/root/SceneManager/CurrentScene").get_children().back().find_node("Player")

func get_scene_manager():
	return get_node("/root/SceneManager")
