extends Node2D

signal action_finished
signal all_actions_finished
signal typing_finished
signal typing_confirmed

enum ActionType { POKEMON_MOVE, USE_ITEM, SWITCH_POKEMON }

const TYPING_SPEED = 16.0 # chars / second
const TYPING_DELAY = 0.6 # seconds

var awaiting_commands: bool = true
var awaiting_confirmation: bool = false
var rng = RandomNumberGenerator.new()
var typing: bool = false
var player_pokemon = null
var enemy_pokemon = null
var planned_action = null

func _ready():
	# TODO: Get first pokemon from party
	# DEBUG:
	var debug_player_pokemon = load("res://Objects/Pokemon.tscn").instance()
	var oddish = load("res://Pokemon Data/Oddish.tres")
	debug_player_pokemon.base_data = oddish
	debug_player_pokemon.moves.append({
		"base_move": load("res://Move Data/Tackle.tres"),
		"pp": 35,
		"max_pp": 35,
	})
	debug_player_pokemon.level = 18
	debug_player_pokemon.max_hp = 43
	debug_player_pokemon.hp = 43
	debug_player_pokemon.attack = 50
	debug_player_pokemon.special_attack = 75
	set_player_pokemon(debug_player_pokemon)
	
	var debug_enemy_pokemon = load("res://Objects/Pokemon.tscn").instance()
	var poliwag = load("res://Pokemon Data/Poliwag.tres")
	debug_enemy_pokemon.base_data = poliwag
	debug_enemy_pokemon.max_hp = 48
	debug_enemy_pokemon.hp = 48
	debug_enemy_pokemon.level = 14
	debug_enemy_pokemon.defence = 40
	debug_enemy_pokemon.special_defence = 40
	set_enemy_pokemon(debug_enemy_pokemon)
	# /DEBUG
	
	$Moves.visible = false
	$Actions.visible = false
	$TextBox/Confirm.visible = false
	
	# rng.randomize()
	get_user_action()

func set_player_pokemon(pokemon):
	if player_pokemon:
		$PlayerPokemon.remove_child(player_pokemon)
	player_pokemon = pokemon
	$PlayerPokemon.add_child(player_pokemon)
	$PlayerPokemon/Stats/Name.text = player_pokemon.get_name()
	$PlayerPokemon/Stats/Health.max_value = player_pokemon.max_hp
	$PlayerPokemon/Stats/Health.value = player_pokemon.hp
	$PlayerPokemon/Stats/HealthNumber.text = "%d/%d" % [player_pokemon.hp, player_pokemon.max_hp]
	$PlayerPokemon/Stats/Experience.value = player_pokemon.experience
	# TODO: Set sprites

func set_enemy_pokemon(pokemon):
	if enemy_pokemon:
		$EnemyPokemon.remove_child(enemy_pokemon)
	enemy_pokemon = pokemon
	$EnemyPokemon.add_child(enemy_pokemon)
	$EnemyPokemon/Stats/Name.text = enemy_pokemon.get_name()
	$EnemyPokemon/Stats/Health.max_value = enemy_pokemon.max_hp
	$EnemyPokemon/Stats/Health.value = enemy_pokemon.hp

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
		# TODO: Move confirmation to end of text (use RichTextLabel and have it
		#       as an icon?)
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
	var damage: float = 0.4 * attacker.level + 2
	damage *= attack.power
	if attack.category == Move.Category.PHYSICAL:
		damage *= (attacker.attack + attacker.attack_boost)
		damage /= (defender.defence + defender.defence_boost)
	elif attack.category == Move.Category.SPECIAL:
		damage *= (attacker.special_attack + attacker.special_attack_boost)
		damage /= (defender.special_defence + defender.special_defence_boost)
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
	for type in defender.get_types():
		type_factor *= Types.get_effectiveness(attack.type, type)
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
	hit_chance *= attack.accuracy
	hit_chance *= attacker.accuracy
	hit_chance *= (1 - defender.evasion)
	return hit_chance

func begin_actions():
	# TODO: Test results against web calculators
	
	awaiting_commands = false
	$Moves.visible = false
	$Actions.visible = false
	# TODO: Work out who attacks/acts first
	#       http://www.psypokes.com/lab/priority.php
	var first_actor = player_pokemon
	var second_actor = enemy_pokemon
	
	var first_action
	var second_action
	
	if first_actor == player_pokemon:
		first_action = planned_action
		second_action = {} # TODO: Get enemy action
	else:
		first_action = {} # TODO: Get enemy action
		second_action = planned_action
	
	# TODO: Handle status effects that would stop an attack
	var first_actor_cannot_act = false
	if first_actor_cannot_act:
		pass
	else:
		match first_action["action_type"]:
			ActionType.POKEMON_MOVE:
				playout_attack(first_action["move"], first_actor, second_actor)
				yield(self, "action_finished")
			ActionType.SWITCH_POKEMON:
				# TODO: Check for pursuit and if if not then switch pokemon
				pass
			ActionType.USE_ITEM:
				pass
	
	# TODO: Check if second pokemon has fainted
	
	# SECOND_ACTION
	# TODO: Handle status effects that would stop an attack
	var second_actor_cannot_act = true
	if second_actor_cannot_act:
		type_text("Wild Poliwag is paralyzed!\nIt cannot move!")
		yield(self, "typing_finished")
		clear_text()
	else:
		match second_action["action_type"]:
			ActionType.POKEMON_MOVE:
				playout_attack(second_action["move"], second_actor, first_actor)
				yield(self, "action_finished")
			ActionType.SWITCH_POKEMON:
				# TODO: Check for pursuit and if if not then switch pokemon
				pass
			ActionType.USE_ITEM:
				pass
				
	# TODO: Check if first pokemon has fainted
	
	emit_signal("all_actions_finished")
	get_user_action()

func playout_attack(move, attacker, defender):
	move["pp"] -= 1
	var attack = move["base_move"]
	type_text("%s used %s!" % [attacker.get_name(), attack.move_name])
	yield(self, "typing_finished")
	clear_text()
	var hit_chance = _get_attack_hit_chance(attack, attacker, defender)
	if rng.randf() < hit_chance:
		$PlayerPokemon/AnimationPlayer.play(attack.move_name)
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
	emit_signal("action_finished")

func attempt_flee():
	$Actions.visible = false
	type_text("Cannot escape!", true)
	yield(self, "typing_confirmed")
	clear_text()
	get_user_action()

func open_bag():
	pass

func open_pokemon_list():
	pass

func get_user_action():
	$Actions.visible = true
	$Moves.visible = false
	$TextBox/Text.text = "What will\n%s do?" % player_pokemon.get_name()
	$TextBox/Text.percent_visible = 1.0
	yield($TextBox/TypeTween, "tween_all_completed")
	awaiting_commands = true

func action_selected(index):
	match index:
		0: open_moves()
		1: open_bag()
		2: open_pokemon_list()
		3: attempt_flee()

func open_moves():
	$Moves.open(player_pokemon)

func move_selected(move):
	# TODO: Handle targetting moves (for multi-battles)
	planned_action = {
		"action_type": ActionType.POKEMON_MOVE,
		"move": move,
		"item": null,
		"next_pokemon": null,
		"target": null
	}
	begin_actions()

func cancel_moves():
	$Moves.visible = false

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
	elif $Moves.visible:
		$Moves.handle_input(event)
	elif $Actions.visible:
		$Actions.handle_input(event)
