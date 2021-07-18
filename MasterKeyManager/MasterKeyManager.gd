extends Node

signal refreshed

var master_keys = []
var master_key_file = "user://master_keys.json"
var encryption_key = "asdfhonadifnaoiugfaisgdfnoais"

var leaderboards = []

func _ready():
	if !File.new().file_exists(master_key_file):
		save_master_keys([])
		
	load_master_keys()
	
# takes an array of keys and OVERWRITES the current file
func save_master_keys(keys):
	var file = File.new()
	if file.open_encrypted_with_pass(master_key_file, File.WRITE, encryption_key) != 0:
		print("Error opening file")
		return

	file.store_line(to_json(keys))
	file.close()
	
# Adds one key to the file and the global varible
func add_master_key(key):
	master_keys.append(key)
	save_master_keys(master_keys)
	

func load_master_keys():
	var file = File.new()
	file.open_encrypted_with_pass(master_key_file, File.READ, encryption_key)
	var data = parse_json(file.get_as_text())
	master_keys = data
	return data
	

func on_board_recieved(data, data_type):
	if !data:
		return
	if data_type != RequestManager.WAIT_FOR.LEADERBOARD_LIST:
		return 
	leaderboards = []
	for board in data:
		if !board:
			continue;
		var leaderboard = preload("res://MasterKeyManager/Leaderboard.tscn").instance()
		leaderboard.board_name = board.name
		leaderboard.highscore = board.highscore
		leaderboard.encryption_key = board.encryption_key
		leaderboard.public_key = board.public_key
		leaderboard.entry_count = board.entry_count
		leaderboard.master_key = board.master_key
		leaderboards.append(leaderboard)
	emit_signal("refreshed")
	RequestManager.disconnect("data_recieved", self, "on_board_recieved")

func refresh():
	RequestManager.connect("data_recieved", self, "on_board_recieved")
	RequestManager.get_leaderboard_list(master_keys)
