tool
extends ColorRect


export var text = "" setget set_text
export var how_to = true


# Called when the node enters the scene tree for the first time.
func _ready():
	$IconButton.visible = how_to
	$Version.text = Global.version


func set_text(value):
	text = value
	$Label.text = text


func _on_IconButton_pressed():
	get_tree().change_scene("res://Scenes/Pages/HowTo/HowTo.tscn")
