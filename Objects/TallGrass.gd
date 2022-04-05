extends Node2D

const GRASS_OVERLAY_TEXTURE = preload("res://Assets/Grass/stepped_tall_grass.png")
const GRASS_STEP_EFFECT = preload("res://Objects/GrassStepEffect.tscn")

var grass_overlay: TextureRect = null
var player_inside: bool = false

onready var anim_player = $AnimationPlayer

func _ready():
	var player = Utils.get_player()
	player.connect("player_moving_signal", self, "player_exiting_grass")
	player.connect("player_stopped_signal", self, "player_in_grass")

func player_exiting_grass():
	player_inside = false
	if is_instance_valid(grass_overlay):
		grass_overlay.queue_free()

func player_in_grass():
	if player_inside == true:
		var grass_step_effect = GRASS_STEP_EFFECT.instance()
		grass_step_effect.position = position
		get_tree().current_scene.add_child(grass_step_effect)
		grass_overlay = TextureRect.new()
		grass_overlay.texture = GRASS_OVERLAY_TEXTURE
		grass_overlay.rect_position = position
		get_tree().current_scene.add_child(grass_overlay)

func _on_Area2D_body_entered(body):
	player_inside = true
	anim_player.play("Stepped")
