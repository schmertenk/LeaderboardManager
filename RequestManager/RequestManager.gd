extends Node

signal data_recieved(data, type)
signal timeoutout(type)

enum WAIT_FOR {
	NOTHING,
	HIGHSCORE_FOR_PLAYER,
	HIGHSCORE_FOR_PLACE,
	HIGHSCORE_FOR_PLACES,
	LEADERBOARD_LIST,
	NEW_LEADERBOARD_DATA,
	DELETE_LEADERBOARD_DATA,
	UPDATE_LEADERBOARD_DATA,
	BLOCK_PLAYER_DATA,
	DELETE_ENTRY_DATA
}


var host = "https://www.kitchen-games.de/leaderboard"
var master_host = "https://www.kitchen-games.de/leaderboard/master"

var config_file_path = "res://config.cfg"

onready var aes = preload("res://RequestManager/AES.tscn").instance()


var http_request
var waiting_for = WAIT_FOR.NOTHING # the flag to determine which data is expected when the request is done
var time_out_timer
var loading_mask
var timeout_mask


func _ready():
	loading_mask = preload("res://RequestManager/LoadingMask/LoadingMask.tscn").instance()
	timeout_mask = preload("res://RequestManager/TimeOutMask/TimeOutMask.tscn").instance()
	time_out_timer = Timer.new()
	time_out_timer.wait_time = 5
	time_out_timer.connect("timeout", self, "on_timeout")
	add_child(time_out_timer)
	http_request = HTTPRequest.new()
	http_request.connect("request_completed", self, "_on_request_completed")
	connect("data_recieved", self, "_on_data_recieved")
	
	add_child(http_request)
	



func _on_request_completed(_result, response_code, _headers, body):
	if response_code != 200 or waiting_for == WAIT_FOR.NOTHING:
		return
	var t = body.get_string_from_utf8()
	if body.get_string_from_utf8():
		var json = JSON.parse(body.get_string_from_utf8())
		if json.error == 0:
			emit_signal("data_recieved", json.result, waiting_for)
		else:
			print("The recieved data with datatype " + WAIT_FOR.keys()[waiting_for] + " could not be decoded. \n", body.get_string_from_utf8())
	time_out_timer.stop()
	waiting_for = WAIT_FOR.NOTHING
	loading_mask.hide()

	
	
func on_timeout():
	emit_signal("timeout", waiting_for)
	if timeout_mask.get_parent():
		timeout_mask.get_parent().remove_child(timeout_mask)
	get_node("/root").call_deferred("add_child", timeout_mask)
	loading_mask.hide()


func get_highscore_for_player(_player_id, public_key, befor = 0, after = 0):
	var url = host + "/get_entry.php?public_key=" + str(public_key)  + "&name=" + _player_id.http_escape() + "&befor=" + str(befor) + "&after=" + str(after)
	send_request(url, WAIT_FOR.HIGHSCORE_FOR_PLAYER)
	
	
func get_highscore_for_places(public_key, from, to):
	from = max(from, 1)
	var url = host + "/get_entries.php?public_key=" + str(public_key)  + "&from=" + str(from) + "&to=" + str(to) + "&with_blocked=1"
	send_request(url, WAIT_FOR.HIGHSCORE_FOR_PLACES)


# takes an array of master keys rquests a list of boards
func get_leaderboard_list(master_keys):
	var key_string = ""
	for key in master_keys:
		key_string += str(key)
		key_string += "_"
	var url = host + "/get_leaderboards.php?master_keys=" + str(key_string)
	send_request(url, WAIT_FOR.LEADERBOARD_LIST)


func add_new_leaderboard(board_name):
	send_request(host + "/new_leaderboard.php?name=" + str(board_name), WAIT_FOR.NEW_LEADERBOARD_DATA)


func delete_leaderboard(master_key):
	send_request(master_host + "/delete_leaderboard.php?master_key=" + str(master_key), WAIT_FOR.DELETE_LEADERBOARD_DATA)
	
	
func update_leaderboard(master_key, board_name, encryption_key, lower_better):
	var url = master_host + "/update_leaderboard.php?master_key=" + str(master_key) + "&name=" + str(board_name) + "&encryption_key=" + str(encryption_key) + "&lower_better=" + str(lower_better)
	send_request(url, WAIT_FOR.UPDATE_LEADERBOARD_DATA)


func delete_entry(id, master_key):
	var url = master_host + "/delete_entry.php?master_key=" + str(master_key) + "&id=" + str(id)
	send_request(url, WAIT_FOR.DELETE_ENTRY_DATA)

func block_player(id, master_key):
	var url = master_host + "/block_player.php?master_key=" + str(master_key) + "&id=" + str(id)
	send_request(url, WAIT_FOR.BLOCK_PLAYER_DATA)


func send_request(url, data_type):
	http_request.cancel_request()
	var _err = http_request.request(url)
	waiting_for = data_type
	time_out_timer.start()
	show_loading_mask()


func show_loading_mask():
	loading_mask.hide()
	if loading_mask.get_parent():
		loading_mask.get_parent().remove_child(loading_mask)
	get_node("/root").call_deferred("add_child", loading_mask)
	loading_mask.show()
	
	
	
func _on_data_recieved(data, data_type):
	pass

