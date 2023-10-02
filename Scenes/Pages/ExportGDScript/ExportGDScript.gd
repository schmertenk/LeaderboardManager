extends Control


onready var board = Global.current_leaderboard_in_view
var export_for_godot4 = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if board:
		$VBoxContainer/Control/VBoxContainer2/Godot3Container/CenterContainer/HBoxContainer/ExportButton.text = "Export Highscoremanager for " + str(board.board_name)
		$VBoxContainer/Control/VBoxContainer2/Godot4Container/CenterContainer/HBoxContainer/ExportButton.text = "Export Highscoremanager for " + str(board.board_name)
	
	
func make_export_script(board, for_godot_4 = false):
	var template = Template.new()
	if for_godot_4:
		template = TemplateGodot4.new()
	var text = template.text
	text = text.replace("[[[public_key]]]", board.public_key)
	text = text.replace("[[[encryption_key]]]", board.encryption_key)
	text = text.replace("[[[low_wins]]]", "true" if board.low_wins else "false")
	return text


func _on_ExportButton_pressed():
	if !Global.web:
		$FileDialog.current_dir= "C:/User/" + OS.get_environment("USERNAME") + "/Desktop/"
		$FileDialog.popup_centered()
		$FileDialog.connect("file_selected", self, "on_file_selected")
	else:
		JavaScript.eval('var element = document.createElement("a");'+
		'element.setAttribute("href","data:text/plain;charset=utf-8," + encodeURIComponent(' + JSON.print(make_export_script(board)) + '));'+
		'element.setAttribute("download", "HighscoreManager.gd");'+
		'document.body.appendChild(element);'+
		'element.click();')
	
func on_file_selected(path):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(make_export_script(board, export_for_godot4))
	file.close()
	export_for_godot4 = false


func _on_CopyCodeButton_pressed():
	if board:
		OS.set_clipboard(make_export_script(board))


func _on_G4CopyCodeButton_pressed():
	if board:
		OS.set_clipboard(make_export_script(board, true))


func _on_G4ExportButton_pressed():
	export_for_godot4 = true
	if !Global.web:
		$FileDialog.current_dir= "C:/User/" + OS.get_environment("USERNAME") + "/Desktop/"
		$FileDialog.popup_centered()
		$FileDialog.connect("file_selected", self, "on_file_selected")
	else:
		JavaScript.eval('var element = document.createElement("a");'+
		'element.setAttribute("href","data:text/plain;charset=utf-8," + encodeURIComponent(' + JSON.print(make_export_script(board)) + '));'+
		'element.setAttribute("download", "HighscoreManager.gd");'+
		'document.body.appendChild(element);'+
		'element.click();')


func _on_Godot3_pressed():
	$VBoxContainer/Control/VBoxContainer2/Godot3Container.visible = true
	$VBoxContainer/Control/VBoxContainer2/Godot4Container.visible = false


func _on_Godot4_pressed():
	$VBoxContainer/Control/VBoxContainer2/Godot3Container.visible = false
	$VBoxContainer/Control/VBoxContainer2/Godot4Container.visible = true
