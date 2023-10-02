extends Object

class_name TemplateGodot4


var text = """
extends Node

signal data_recieved(data, type)
signal timeout(type)

enum WAIT_FOR {
	NOTHING,
	HIGHSCORE_FOR_PLAYER,
	HIGHSCORE_FOR_PLACES,
	SUBMISSION_INFO,
	PLAYER_DATA
}


# set in config file under [Highscore]
var public_key = "[[[public_key]]]"
var low_wins = [[[low_wins]]]

# change the version when your game changes in a way that could reguard the highscores
# for example changing difficulty or score calculation
# changing this will reset the leaderboard (but won't delete the entries. you can go back a version any time)
var version = "0.1"

var host = "https://www.kitchen-games.de/leaderboard"

#the score file is encrypted to prevent cheating
var highscore_file = "user://encrypted_score.json"

# the key to encrypt the highscore file and the score submitted to the server
# is has to be exactly 16 chars and the same as configured for the board on the server
var encryption_key = "[[[encryption_key]]]"

# the private key is generated by the server and gets saved here when you submit a score the first time
var private_key_file = "user://private_key.json"
var private_key = null
var player_id = null

# loading from score file
var player_name = null

var adjectives = [
	"Happy", "Shiny", "Brave", "Sparkling", "Enormous", "Playful", "Mysterious",
	"Graceful", "Colorful", "Silky", "Radiant", "Majestic", "Dazzling", "Elegant",
	"Tranquil", "Joyful", "Glowing", "Vibrant", "Peaceful", "Whimsical", "Magical",
	"Curious", "Serene", "Charming", "Adorable", "Cheerful", "Puzzling", "Delightful",
	"Lively", "Quirky", "Sincere", "Talented", "Tender", "Unique", "Wonderful", "Zesty",
	"Creative", "Dreamy", "Fancy", "Gentle", "Honest", "Imaginative", "Jovial",
	"Kindhearted", "Luxurious", "Modest", "Optimistic", "Fierce", "Swift", "Clever",
	"Glorious", "Noble", "Fearless", "Humble", "Wise", "Witty", "Adventurous", "Cunning",
	"Mighty", "Chivalrous", "Courageous", "Epic", "Legendary", "Mischievous", "Nimble"
]
var nouns = [
	"Elephant", "Lion", "Dog", "Kitten", "Eagle", "Dolphin", "Penguin",
	"Squirrel", "Shark", "Parrot", "Cheetah", "Butterfly", "Rhino", "Panda",
	"Giraffe", "Owl", "Wolf", "Squirrel", "Turtle", "Fox", "Gorilla",
	"Gazelle", "Flamingo", "Bumblebee", "Swan", "Crocodile", "Snake", "Kangaroo",
	"Koala", "Lizard", "Ant", "Mole", "Horse", "Deer", "Lizard",
	"Pig", "Monkey", "Sheep", "Donkey", "Tiger", "Hedgehog", "Fish", "Sparrow",
	"Rabbit", "Bee", "Crow", "Cow", "Chicken", "Goose", "Duck",
	"Bumblebee", "Lynx", "Bat", "Pig", "Hamster"
]

var pending_requests = {}

@onready var json = JSON.new()
@onready var aes = AESContext.new()


func _ready():
	data_recieved.connect(_on_data_recieved)
	
	if !FileAccess.file_exists(highscore_file):
		make_local_highscore_file()
		
	if !FileAccess.file_exists(private_key_file):
		save_private_key(null, null)
		
	player_name = load_player_name()
	private_key = load_private_key()
	player_id = load_player_id()
	
	var local_data = load_local_data()
	if local_data and (!local_data.keys().has("submitted") or local_data.submitted == false) and (local_data.keys().has("version") and local_data.version == version):
		#if there is something to sync please do so
		#sync the global and the local score, in case the highscore was beaten when playing offline
		submit_highscore(load_local_highscore())

	
# local highscore administration
func load_player_name():
	return load_local_data().player_name
	

func load_local_highscore():
	return load_local_data().highscore


func is_local_score_submitted():
	var data = load_local_data()
	return data.keys().has("submitted") and data.submitted
	
	
func load_local_data():
	var file = FileAccess.open_encrypted_with_pass(highscore_file, FileAccess.READ, encryption_key)
	if !file:
		print("error opening highscore file")
		return 
	json.parse(file.get_as_text())
	var data = json.data
	return data
	
	
func save_local_highscore(score, initial = false):
	# just save the local highscore if its actually better than the last. elsubmitse return
	if load_local_highscore() != null and (low_wins && score >= load_local_highscore() or !low_wins && score <= load_local_highscore()):
		#overwrite even better scores when version has changed
		if load_local_data().keys().has("version") and load_local_data().version == version:
			return
	var file = FileAccess.open_encrypted_with_pass(highscore_file, FileAccess.WRITE, encryption_key)
	if !file:
		print("Error opening file")
		return

	file.store_line(json.stringify({"player_name": player_name, "highscore": score, "submitted": false, "version" : version}))
	file.close()
	
func mark_local_score_as_submitted():
	var local_data = load_local_data()
	var file = FileAccess.open_encrypted_with_pass(highscore_file, FileAccess.WRITE, encryption_key)
	if !file:
		print("Error opening file")
		return
	file.store_line(json.stringify({"player_name": player_name, "highscore": local_data.highscore, "submitted": true}))
	file.close()


# private_key administration
func save_private_key(player_id, private_key):
	var file = FileAccess.open(private_key_file, FileAccess.WRITE)
	if !file:
		print("Error opening file")
		return

	file.store_line(json.stringify({"player_id": player_id, "private_key": private_key}))
	file.close()


func load_private_key():
	var file = FileAccess.open(private_key_file, FileAccess.READ)
	json.parse(file.get_as_text())
	var data = json.data
	return data.private_key


func load_player_id():
	var file = FileAccess.open(private_key_file, FileAccess.READ)
	json.parse(file.get_as_text())
	var data = json.data
	return data.player_id
	
	
func generate_player_name():
	randomize()
	return adjectives[randi() % adjectives.size()] + " and " + adjectives[randi() % adjectives.size()] + " " + nouns[randi() % nouns.size()]


func make_local_highscore_file():
	player_name = generate_player_name()
	var file = FileAccess.open_encrypted_with_pass(highscore_file, FileAccess.WRITE, encryption_key)
	if !file:
		print("Error opening file")
		return

	file.store_line(json.stringify({"player_name": player_name, "highscore": null, "version": version, "submitted": true}))
	file.close()


func get_highscore_for_player(_player_id, before = 0, after = 0, callable = null):
	var info = create_request(callable)
	var url = host + "/get_entry.php?public_key=" + str(public_key)  + "&player_id=" + _player_id + "&before=" + str(before) + "&after=" + str(after) + "&request_id=" + str(info.request_id) + "&version=" + version
	var _err = info.http_request.request(url)
	info.reason = WAIT_FOR.HIGHSCORE_FOR_PLAYER
	pending_requests[info.request_id] = info
	
	
func get_highscore_for_places(from, to, callable = null):
	var info = create_request(callable)
	from = max(from, 1)
	var url = host + "/get_entries.php?public_key=" + str(public_key)  + "&from=" + str(from) + "&to=" + str(to) + "&request_id=" + str(info.request_id) + "&version=" + version
	var _err = info.http_request.request(url)
	info.reason = WAIT_FOR.HIGHSCORE_FOR_PLACES
	pending_requests[info.request_id] = info
	print(url)
	
	
func submit_highscore(highscore, callable = null):
	var info = create_request(callable)
	var encrypted_highscore = encrypt_score(highscore)
	var url
	if private_key && player_id:
		url = str(host + "/submit_entry.php?public_key=" + str(public_key) + "&private_key=" + str(private_key) + "&player_id=" + str(player_id) + "&score=" + str(encrypted_highscore) + "&request_id=" + str(info.request_id)) + "&version=" + version
		info.reason = WAIT_FOR.SUBMISSION_INFO
	else:
		url = str(host + "/add_player_and_submit_entry.php?public_key=" + str(public_key) + "&name=" + player_name.uri_encode() + "&score=" + str(encrypted_highscore) + "&request_id=" + str(info.request_id)) + "&version=" + version
		info.reason = WAIT_FOR.PLAYER_DATA
	
	var _err = info.http_request.request(url, ["User-Agent: Pirulo/1.0 (Godot)","Accept: */*"], HTTPClient.METHOD_GET)
	pending_requests[info.request_id] = info
	print(url)
	
func _on_data_recieved(data):
	if pending_requests.has(int(data.request_id)):
		var info:HighscoreRequestInfo = pending_requests[int(data.request_id)]
		pending_requests.erase(int(data.request_id))
		if info.callable:
			info.callable.call(data)
		if info.reason == WAIT_FOR.PLAYER_DATA:
			if data.ok && data.private_key && data.player_id:
				save_private_key(data.player_id, data.private_key)
				private_key = load_private_key()
				player_id = load_player_id()
		if info.reason == WAIT_FOR.SUBMISSION_INFO:
			mark_local_score_as_submitted()
				

	
func _on_request_completed(_result, response_code, _headers, body):
	if response_code != 200:
		return
	json.parse(body.get_string_from_utf8())
	emit_signal("data_recieved", json.data)
	
	
func encrypt_score(score):
	aes.start(AESContext.MODE_ECB_ENCRYPT, encryption_key.to_utf8_buffer())
	var highscore_array = str(score).to_utf8_buffer()
	var padding = 16 - (highscore_array.size() % 16)
	for i in range(padding):
		highscore_array.append(padding)
	
	var encrypted_highscore = pool_byte_array_to_byte_string(aes.update(highscore_array))
	aes.finish()
	return encrypted_highscore
	
	
func pool_byte_array_to_byte_string(array):
	var string = ""
	for byte in array:
		string += str(byte)
		string += "_"
	
	return string
	

func create_request(callable):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	var request_id = randi_range(0,99999999)
	var info = HighscoreRequestInfo.new()
	info.request_id = request_id
	info.http_request = http_request
	if callable:
		info.callable = callable
	return info

class HighscoreRequestInfo:
	var http_request:HTTPRequest
	var reason
	var callable:Callable
	var request_id

"""
