extends Control

onready var board = Global.current_leaderboard_in_view

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/PageTitle.text = "Edit: " + str(board.board_name)
	$VBoxContainer/Control/VBoxContainer/Name/TextEdit.text = str(board.board_name)
	$VBoxContainer/Control/VBoxContainer/PublicKey/TextEdit.text = str(board.public_key)
	$VBoxContainer/Control/VBoxContainer/EncryptionKey/TextEdit.text = str(board.encryption_key)
	$VBoxContainer/Control/VBoxContainer/MasterKey/TextEdit.text = str(board.master_key)


func _on_QuestionButton_name_pressed():
	$VBoxContainer/Control/VBoxContainer/Name/Answer.visible = !$VBoxContainer/Control/VBoxContainer/Name/Answer.visible


func _on_QuestionButton_encryption_pressed():
	$VBoxContainer/Control/VBoxContainer/EncryptionKey/Answer.visible = !$VBoxContainer/Control/VBoxContainer/EncryptionKey/Answer.visible


func _on_QuestionButton_public_pressed():
	$VBoxContainer/Control/VBoxContainer/PublicKey/Answer.visible = !$VBoxContainer/Control/VBoxContainer/PublicKey/Answer.visible


func _on_QuestionButton_master_pressed():
	$VBoxContainer/Control/VBoxContainer/MasterKey/Answer.visible = !$VBoxContainer/Control/VBoxContainer/MasterKey/Answer.visible


func _on_RemoveButton_pressed():
	MasterKeyManager.master_keys.erase(board.master_key)
	MasterKeyManager.save_master_keys(MasterKeyManager.master_keys)
	MasterKeyManager.leaderboards.erase(board)
	get_tree().change_scene("res://Scenes/Pages/LeaderboardList/LeaderboardList.tscn")


func _on_DeleteButton_pressed():
	RequestManager.delete_leaderboard(board.master_key)
	RequestManager.connect("data_recieved", self, "on_leaderboard_deleted")
	
func on_leaderboard_deleted(data, data_type):
	RequestManager.disconnect("data_recieved", self, "on_leaderboard_deleted")
	if data_type != RequestManager.WAIT_FOR.DELETE_LEADERBOARD_DATA:
		return
	if !data.ok:
		print(data.message)
		return
		
	MasterKeyManager.master_keys.erase(board.master_key)
	MasterKeyManager.save_master_keys(MasterKeyManager.master_keys)
	MasterKeyManager.leaderboards.erase(board)
	get_tree().change_scene("res://Scenes/Pages/LeaderboardList/LeaderboardList.tscn")


func _on_SubmitChangesButton_pressed():
	var board_name = $VBoxContainer/Control/VBoxContainer/Name/TextEdit.text
	var encryption_key = $VBoxContainer/Control/VBoxContainer/EncryptionKey/TextEdit.text
	RequestManager.update_leaderboard(board.master_key, board_name, encryption_key)


func _on_ResetChanges_pressed():
	$VBoxContainer/Control/VBoxContainer/Name/TextEdit.text = board.board_name
	$VBoxContainer/Control/VBoxContainer/EncryptionKey/TextEdit.text = board.encryption_key
	


func _on_GenerateGDScriptButtin_pressed():
	get_tree().change_scene("res://Scenes/Pages/ExportGDScript/ExportGDScript.tscn")
