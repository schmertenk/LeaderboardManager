extends Control

var leaderboard = Global.current_leaderboard_in_view

func _ready():
	$VBoxContainer/PageTitle.text = str(leaderboard.board_name)
	RequestManager.get_highscore_for_places(leaderboard.public_key, 1,10000)
	RequestManager.connect("data_recieved", self, "_on_data_recieved")

	
func _on_data_recieved(data, data_type):
	if data_type == RequestManager.WAIT_FOR.HIGHSCORE_FOR_PLACES:
		if !data:
			return
		for e in $VBoxContainer/ScrollContainer/SlotContainer.get_children():
			if e != $VBoxContainer/ScrollContainer/SlotContainer.get_child(0):
				$VBoxContainer/ScrollContainer/SlotContainer.remove_child(e)
				
		for e in data:
			var entry = preload("res://Scenes/Pages/ViewLeaderboard/Entry.tscn").instance()
			entry.player_name = e.name
			entry.score = e.score
			entry.place = e.place
			entry.submissions = e.submission_count
			entry.id = e.id
			entry.blocked = e.blocked
			entry.player_id = e.player
			$VBoxContainer/ScrollContainer/SlotContainer.add_child(entry)
			entry.connect("updated", self, "on_list_updated")
			

func on_list_updated():
	get_tree().change_scene("res://Scenes/Pages/ViewLeaderboard/ViewLeaderboard.tscn")
