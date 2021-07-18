extends Control

signal updated

var player_name setget set_player_name
var place setget set_place
var score setget set_score
var submissions setget set_submissions
var blocked setget set_blocked
var id
var player_id


func _ready():
	RequestManager.connect("data_recieved", self, "on_data_recieved")

func set_player_name(value):
	player_name = value
	$VBoxContainer/HBoxContainer/name.text = str(value)

func set_place(value):
	place = value
	$VBoxContainer/HBoxContainer/place.text = str(value)

func set_score(value):
	score = value
	$VBoxContainer/HBoxContainer/score.text = str(value)

func set_submissions(value):
	submissions = value
	$VBoxContainer/HBoxContainer/submissions.text = str(value)

func set_blocked(value):
	blocked = value
	if blocked:
		modulate = Color (0.8,0.2,0.2, 1.5)
		$VBoxContainer/HBoxContainer/BlockButton.button_text = "Unblock Player"


func _on_DeleteButton_pressed():
	RequestManager.delete_entry(id, Global.current_leaderboard_in_view.master_key)
	
	
func on_data_recieved(data, data_type):
	if data_type == RequestManager.WAIT_FOR.DELETE_ENTRY_DATA or data_type == RequestManager.WAIT_FOR.BLOCK_PLAYER_DATA:
		if data.ok:
			emit_signal("updated")


func _on_BlockButton_pressed():
	RequestManager.block_player(player_id, Global.current_leaderboard_in_view.master_key)
