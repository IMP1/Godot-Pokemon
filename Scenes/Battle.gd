extends Node2D

signal actions_finished

var awaiting_commands: bool = true
var rng = RandomNumberGenerator.new()

onready var action_cursor = $TextBox/Actions/Cursor
onready var move_cursor = $TextBox/Moves/Cursor

func _ready():
	# rng.randomize()
	$TextBox/Moves.visible = false
	$TextBox/Actions.visible = false
	$EnemyPokemon/Stats/Health.max_value = 48 # TODO: Get enemy pokemon stats
	$EnemyPokemon/Stats/Health.value = 48 # TODO: Get enemy pokemon current hp
	get_user_action()

func type_text(message: String):
	var TYPE_SPEED = 10 # chars per second
	$TextBox/Text.text = message
	var text_len = $TextBox/Text.text.length()
	var duration = text_len / TYPE_SPEED
	$TextBox/TypeTween.interpolate_property($TextBox/Text, "visible_characters", 0, text_len, duration)
	$TextBox/TypeTween.start()

func _get_attack_damage(attack, attacker, defender) -> int:
	# https://bulbapedia.bulbagarden.net/wiki/Damage
	# Base Damage
	var damage: float = 0.4 * attacker["level"] + 2
	damage *= attack["power"]
	if attack["is_physical"]:
		damage *= attacker["attack"]
		damage /= defender["defence"]
	else:
		damage *= attacker["special_attack"]
		damage /= defender["special_defence"]
	damage /= 50
	damage += 2
	# TODO: Targets
	# TODO: Weather
	# TODO: Badge
	# TODO: Critical
	# TODO: Random
	var random = rng.randf_range(0.85, 1.0)
	damage *= random
	# TODO: STAB
	var stab: float = 1.0
	damage *= stab
	# TODO: Type Effectiveness
	var type_factor: float = 1.0
	for type in defender["types"]:
		type_factor *= Types.get_effectiveness(attack["type"], type)
	damage *= type_factor
	# TODO: Burn
	var burn: float = 1.0
	damage *= burn
	# TODO: Other
	var other: float = 1.0
	damage *= other
	if int(damage) <= 0 and type_factor != 0.0:
		damage = 1.0
	return int(damage)

func begin_actions():
	awaiting_commands = false
	$TextBox/Moves.visible = false
	$TextBox/Actions.visible = false
	# TODO: Work out who attacks/acts first
	#       http://www.psypokes.com/lab/priority.php
	
	# FIRST ACTION
	type_text("Oddish used Tackle!")
	# TODO: Does it hit? Accuracy
	var attack = {"power": 40, "is_physical":true, "type":Types.NORMAL}
	var attacker = {"attack":50, "special_attack":75, "level":18}
	var defender = {"defence":40, "special_defence":40, "types":[Types.WATER]}
	var attack_damage = _get_attack_damage(attack, attacker, defender)
	yield($TextBox/TypeTween, "tween_all_completed")
	$PlayerPokemon/AnimationPlayer.play("Tackle")
	yield($PlayerPokemon/AnimationPlayer, "animation_finished")
	$TextBox/Text.text = ""
	$TextBox/Text.visible_characters = 0
	var hp_tween = $EnemyPokemon/Stats/Health/Tween
	var current_hp = $EnemyPokemon/Stats/Health.value
	var target_hp = current_hp - attack_damage
	var damage_speed = 0.1
	hp_tween.interpolate_property($EnemyPokemon/Stats/Health, "value", current_hp, target_hp, damage_speed)
	hp_tween.start()
	yield(hp_tween, "tween_all_completed")
	# TODO: Effects of first attack
	#       (lower health, effective text, status effect, stat effect, etc.)
	
	# TODO: Test results against web calculators
	
	# SECOND_ACTION
	type_text("Wild Poliwag is paralyzed!\nIt cannot move!")
	yield($TextBox/TypeTween, "tween_all_completed")
	$TextBox/Text.text = ""
	# TODO: Play second animation
	# TODO: Effects of section action
	#       (lower health, effective text, status effect, stat effect, etc.)
	# ...
	
	emit_signal("actions_finished")
	get_user_action()

func get_user_action():
	$TextBox/Actions.visible = true
	$TextBox/Moves.visible = false
	$TextBox/Text.text = "What will\nODDISH do?"
	$TextBox/Text.percent_visible = 1.0
	yield($TextBox/TypeTween, "tween_all_completed")
	awaiting_commands = true

func _input(event):
	if not awaiting_commands:
		return
	if $TextBox/Moves.visible:
		if event.is_action_pressed("ui_down"):
			if move_cursor.offset.y == 0:
				move_cursor.offset.y = 16
		if event.is_action_pressed("ui_up"):
			if move_cursor.offset.y == 16:
				move_cursor.offset.y = 0
		if event.is_action_pressed("ui_right"):
			if move_cursor.offset.x == 0:
				move_cursor.offset.x = 78
		if event.is_action_pressed("ui_left"):
			if move_cursor.offset.x == 78:
				move_cursor.offset.x = 0
		if event.is_action_pressed("ui_accept"):
			begin_actions()
	elif $TextBox/Actions.visible:
		if event.is_action_pressed("ui_down"):
			if action_cursor.offset.y == 0:
				action_cursor.offset.y = 16
		if event.is_action_pressed("ui_up"):
			if action_cursor.offset.y == 16:
				action_cursor.offset.y = 0
		if event.is_action_pressed("ui_right"):
			if action_cursor.offset.x == 0:
				action_cursor.offset.x = 56
		if event.is_action_pressed("ui_left"):
			if action_cursor.offset.x == 56:
				action_cursor.offset.x = 0
		if event.is_action_pressed("ui_accept"):
			$TextBox/Moves.visible = true
