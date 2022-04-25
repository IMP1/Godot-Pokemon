extends TextureRect

signal cursor_changed(new_index)
signal action_selected(index)

const X_OFFSET = 63 - 7
const Y_OFFSET = 16

var cursor_index: int = 0
var max_cursor_index: int = 4

onready var cursor = $Cursor

func handle_input(event):
	if event.is_action_pressed("ui_down"):
		if cursor_index < 2 and cursor_index + 2 < max_cursor_index:
			cursor_index += 2
			cursor.rect_position.y += Y_OFFSET
			emit_signal("cursor_changed", cursor_index)
	if event.is_action_pressed("ui_up"):
		if cursor_index >= 2:
			cursor_index -= 2
			cursor.rect_position.y -= Y_OFFSET
			emit_signal("cursor_changed", cursor_index)
	if event.is_action_pressed("ui_right"):
		if cursor_index % 2 == 0 and cursor_index + 1 < max_cursor_index:
			cursor_index += 1
			cursor.rect_position.x += X_OFFSET
			emit_signal("cursor_changed", cursor_index)
	if event.is_action_pressed("ui_left"):
		if cursor_index % 2 == 1:
			cursor_index -= 1
			cursor.rect_position.x -= X_OFFSET
			emit_signal("cursor_changed", cursor_index)
	if event.is_action_pressed("ui_cancel"):
		emit_signal("closing")
	if event.is_action_pressed("ui_accept"):
		emit_signal("action_selected", cursor_index)
