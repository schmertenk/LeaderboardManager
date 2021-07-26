extends Button


func _pressed():
	get_tree().change_scene("res://Scenes/Pages/LeaderboardList/LeaderboardList.tscn")

var active = false setget set_active


func _on_IconButton_mouse_entered():
	self.active = true


func _on_IconButton_mouse_exited():
	self.active = false


func set_active(value):
	active = value
	$ActiveRect.visible = active
