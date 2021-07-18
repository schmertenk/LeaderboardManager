extends Control


onready var board = Global.current_leaderboard_in_view

# Called when the node enters the scene tree for the first time.
func _ready():
	if board:
		$VBoxContainer/Control/VBoxContainer/CenterContainer/ExportButton.text = "Export Highscoremanager for " + str(board.board_name)
	
	
	
func make_export_script(public_key, encryption_key):
	var file = File.new()
	file.open("res://Template.txt", File.READ)
	var text = file.get_as_text()
	text = text.replace("[[[public_key]]]", public_key)
	text = text.replace("[[[encryption_key]]]", encryption_key)
	print(text)
	return text


func _on_ExportButton_pressed():
	$FileDialog.current_dir= "C:/User/" + OS.get_environment("USERNAME") + "/Desktop/"
	$FileDialog.popup_centered()
	$FileDialog.connect("file_selected", self, "on_file_selected")
	
func on_file_selected(path):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(make_export_script(board.public_key, board.encryption_key))
	file.close()
