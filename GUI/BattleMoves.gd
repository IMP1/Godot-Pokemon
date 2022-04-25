extends TextureRect

signal cursor_changed(new_index)
signal move_selected(move)
signal closing

const X_OFFSET = 78
const Y_OFFSET = 16

var pokemon = null
var cursor_index: int = 0
var max_cursor_index: int = 0

onready var cursor = $Cursor

func open(new_pokemon):
	if pokemon != new_pokemon:
		cursor_index = 0
		pokemon = new_pokemon
		for i in range(4):
			var node = $Moves.get_child(i)
			node.text = ""
		for i in range(pokemon.moves.size()):
			var move = pokemon.moves[i]
			var node = $Moves.get_child(i)
			node.text = move["base_move"].move_name
		max_cursor_index = pokemon.moves.size()
	refresh_move_info()
	visible = true

func _move_cursor():
	emit_signal("cursor_changed", cursor_index)
	refresh_move_info()

func handle_input(event):
	if event.is_action_pressed("ui_down"):
		if cursor_index < 2 and cursor_index + 2 < max_cursor_index:
			cursor_index += 2
			cursor.rect_position.y += Y_OFFSET
			_move_cursor()
	if event.is_action_pressed("ui_up"):
		if cursor_index >= 2:
			cursor_index -= 2
			cursor.rect_position.y -= Y_OFFSET
			_move_cursor()
	if event.is_action_pressed("ui_right"):
		if cursor_index % 2 == 0 and cursor_index + 1 < max_cursor_index:
			cursor_index += 1
			cursor.rect_position.x += X_OFFSET
			_move_cursor()
	if event.is_action_pressed("ui_left"):
		if cursor_index % 2 == 1:
			cursor_index -= 1
			cursor.rect_position.x -= X_OFFSET
			_move_cursor()
	if event.is_action_pressed("ui_cancel"):
		emit_signal("closing")
	if event.is_action_pressed("ui_accept"):
		var move = pokemon.moves[cursor_index]
		if move:
			emit_signal("move_selected", move)

func refresh_move_info():
	var move = pokemon.moves[cursor_index]
	$MoveInfo/PP.text = str(move["pp"])
	$MoveInfo/PP_Max.text = str(move["max_pp"])
	pass # TODO: Update PP and Move type
