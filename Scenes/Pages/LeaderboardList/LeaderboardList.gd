extends Control


func _ready():
	MasterKeyManager.refresh()
	MasterKeyManager.connect("refreshed", self, "_on_refresh")
	make_list(MasterKeyManager.leaderboards)
	
	
func make_list(boards):
	var count = 0
	for c in $VBoxContainer/SlotContainer.get_children():
		count += 1
		if count == 1:
			continue
		$VBoxContainer/SlotContainer.remove_child(c)
		
	for board in boards:
		var slot = preload("res://Scenes/Pages/LeaderboardList/LeaderboardSlot.tscn").instance()
		slot.board = board
		slot.connect("slot_view_pressed", self, "_on_slot_view_pressed")
		slot.connect("slot_edit_pressed", self, "_on_slot_edit_pressed")
		$VBoxContainer/SlotContainer.add_child(slot)
	
	
func _on_refresh():
	make_list(MasterKeyManager.leaderboards)
		


func pool_byte_array_to_digit_string(array):
	var string = ""
	for byte in array:
		string += str(byte)
		string += "_"
	
	return string

func _on_slot_view_pressed(board):
	Global.current_leaderboard_in_view = board
	get_tree().change_scene("res://Scenes/Pages/ViewLeaderboard/ViewLeaderboard.tscn")


func _on_slot_edit_pressed(board):
	Global.current_leaderboard_in_view = board
	get_tree().change_scene("res://Scenes/Pages/EditLeaderboard/EditLeaderboard.tscn")
	
func _on_NewButton_pressed():
	get_tree().change_scene("res://Scenes/Pages/NewLeaderboard/NewLeaderboard.tscn")


