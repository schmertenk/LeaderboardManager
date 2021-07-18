extends Control


func _on_CreateButton_pressed():
	$VBoxContainer/Control/Create.visible = true
	$VBoxContainer/Control/Import.visible = false


func _on_ImportButton_pressed():
	$VBoxContainer/Control/Import.visible = true
	$VBoxContainer/Control/Create.visible = false


func _on_import_submission_pressed():
	var new_key = $VBoxContainer/Control/Import/Key/TextEdit.text
	
	if MasterKeyManager.master_keys.has(new_key):
		return
	
	RequestManager.get_leaderboard_list([$VBoxContainer/Control/Import/Key/TextEdit.text])
	RequestManager.connect("data_recieved", self, "_on_leaderbaord_recieved")
	
func _on_leaderbaord_recieved(data, data_type):
	if data_type != RequestManager.WAIT_FOR.LEADERBOARD_LIST:
		return
	
	if data[0]:
		MasterKeyManager.add_master_key(data[0].master_key)
		print("key saved")
	RequestManager.disconnect("data_recieved", self, "_on_leaderbaord_recieved")


func _on_create_board_pressed():
	var board_name = $VBoxContainer/Control/Create/Name/TextEdit.text
	RequestManager.add_new_leaderboard(board_name)
	RequestManager.connect("data_recieved", self, "_on_new_board_data_recieved")


func _on_new_board_data_recieved(data, data_type):
	if data_type != RequestManager.WAIT_FOR.NEW_LEADERBOARD_DATA:
		return
	$VBoxContainer/Control/Create/Data.visible = true
	if data.ok:
		$VBoxContainer/Control/Create/Data/Disclamer.text = "the leaderboard was successfully created.\n here are the keys. Please dont lose the master_key, since you're not able to optain it again."
		$VBoxContainer/Control/Create/Data/name.text = "name: " + str(data.name)
		$VBoxContainer/Control/Create/Data/public_key.text = "public_key: " + str(data.public_key)
		$VBoxContainer/Control/Create/Data/master_key.text = "master_key: " + str(data.master_key)
		$VBoxContainer/Control/Create/Data/encryption_key.text = "encryption_key: " + str(data.encryption_key)
	else:
		$VBoxContainer/Control/Create/Data/Disclamer.text = "An error occured while adding the leaderboard. sorry"
	MasterKeyManager.add_master_key(data.master_key)
	RequestManager.disconnect("data_recieved", self, "_on_new_board_data_recieved")
