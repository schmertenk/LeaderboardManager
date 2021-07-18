extends Control

signal slot_view_pressed()
signal slot_edit_pressed()

var board setget set_board


func set_board(value):
	board = value
	$VBoxContainer/HBoxContainer/name.text = str(board.board_name)
	$VBoxContainer/HBoxContainer/entries.text = str(board.entry_count)
	$VBoxContainer/HBoxContainer/highscore.text = str(board.highscore)


func _on_ViewButton_pressed():
	emit_signal("slot_view_pressed", board)


func _on_EditButton_pressed():
	emit_signal("slot_edit_pressed", board)
