extends Node2D

signal actions_finished
signal typing_finished
signal typing_confirmed

const TYPING_SPEED = 16.0 # chars / second
const TYPING_DELAY = 0.6 # seconds

var awaiting_commands: bool = true
var awaiting_confirmation: bool = false
var rng = RandomNumberGenerator.new()
var typing: bool = false
var player_pokemon = preload("res://Pokemon Data/Oddish.tscn").instance()
var current_pokemon = "ODDISH"

onready var action_cursor = $TextBox/Actions/Cursor
onready var move_cursor = $TextBox/Moves/Cursor

func _ready():
	# rng.randomize()
	$TextBox/Moves.visible = false
	$TextBox/Actions.visible = false
	$TextBox/Confirm.visible = false
	$EnemyPokemon/Stats/Health.max_value = 48 # TODO: Get enemy pokemon stats
	$EnemyPokemon/Stats/Health.value = 48 # TODO: Get enemy pokemon current hp
	get_user_action()

func type_text(message: String, need_confirmation: bool = false):
	$TextBox/Text.text = message
	var text_len = $TextBox/Text.text.length()
	var duration = text_len / TYPING_SPEED
	$TextBox/TypeTween.interpolate_property($TextBox/Text, "visible_characters", 0, text_len, duration)
	$TextBox/TypeTween.start()
	typing = true
	yield($TextBox/TypeTween, "tween_all_completed")
	typing = false
	if need_confirmation:
		$TextBox/Confirm.visible = true
		awaiting_confirmation = true
	else:
		yield(get_tree().create_timer(TYPING_DELAY), "timeout")
	emit_signal("typing_finished")

func skip_text():
	$TextBox/TypeTween.stop_all()
	$TextBox/Text.percent_visible = 1.0
	$TextBox/TypeTween.emit_signal("tween_all_completed")

func clear_text():
	$TextBox/Text.text = ""
	$TextBox/Text.visible_characters = 0

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

func _get_attack_hit_chance(attack, attacker, defender) -> float:
	var hit_chance: float = 1.0
	hit_chance *= attack["accuracy"]
	hit_chance *= attacker["accuracy"]
	hit_chance *= (1 - defender["evasion"])
	return hit_chance

func begin_actions():
	awaiting_commands = false
	$TextBox/Moves.visible = false
	$TextBox/Actions.visible = false
	# TODO: Work out who attacks/acts first
	#       http://www.psypokes.com/lab/priority.php
	
	# FIRST ACTION
	# TODO: Handle status effects that would stop an attack
	type_text("Oddish used Tackle!")
	yield(self, "typing_finished")
	clear_text()
	var attack = {"power": 40, "accuracy": 1.0, "is_physical":true, "type":Types.NORMAL}
	var attacker = {"attack":50, "special_attack":75, "accuracy": 1.0, "level":18}
	var defender = {"defence":40, "special_defence":40, "evasion": 0.0, "types":[Types.WATER]}
	var hit_chance = _get_attack_hit_chance(attack, attacker, defender)
	if rng.randf() < hit_chance:
		$PlayerPokemon/AnimationPlayer.play("Tackle")
		yield($PlayerPokemon/AnimationPlayer, "animation_finished")
		var attack_damage = _get_attack_damage(attack, attacker, defender)
		var hp_tween = $EnemyPokemon/Stats/Health/Tween
		var current_hp = $EnemyPokemon/Stats/Health.value
		var target_hp = current_hp - attack_damage
		var damage_speed = 0.1
		hp_tween.interpolate_property($EnemyPokemon/Stats/Health, "value", current_hp, target_hp, damage_speed)
		hp_tween.start()
		yield(hp_tween, "tween_all_completed")
		# TODO: Effects of first attack
		#       (lower health, effective text, status effect, stat effect, etc.)
	else:
		type_text("But it missed!")
		yield(self, "typing_finished")
		clear_text()
	# TODO: Lower PP
	# TODO: Test results against web calculators
	
	# SECOND_ACTION
	type_text("Wild Poliwag is paralyzed!\nIt cannot move!")
	yield(self, "typing_finished")
	clear_text()
	# TODO: Play second animation
	# TODO: Effects of section action
	#       (lower health, effective text, status effect, stat effect, etc.)
	# ...
	
	emit_signal("actions_finished")
	get_user_action()

func attempt_flee():
	$TextBox/Actions.visible = false
	type_text("Cannot escape!", true)
	yield(self, "typing_confirmed")
	clear_text()
	get_user_action()

func open_bag():
	pass

func open_pokemon_list():
	pass

func get_user_action():
	$TextBox/Actions.visible = true
	$TextBox/Moves.visible = false
	$TextBox/Text.text = "What will\n%s do?" % current_pokemon
	$TextBox/Text.percent_visible = 1.0
	yield($TextBox/TypeTween, "tween_all_completed")
	awaiting_commands = true

func _input(event):
	if typing and event.is_action_pressed("ui_accept"):
		skip_text()
		return
	if not awaiting_commands:
		return
	if awaiting_confirmation and event.is_action_pressed("ui_accept"):
		awaiting_confirmation = false
		$TextBox/Confirm.visible = false
		emit_signal("typing_confirmed")
	elif $TextBox/Moves.visible:
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
		if event.is_action_pressed("ui_cancel"):
			$TextBox/Moves.visible = false
		if event.is_action_pressed("ui_accept"):
			# TODO: Get selected move
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
			match action_cursor.offset:
				Vector2(0, 0):
					$TextBox/Moves.visible = true
				Vector2(56, 0):
					open_bag()
				Vector2(0, 16):
					open_pokemon_list()
				Vector2(56, 16):
					attempt_flee()
