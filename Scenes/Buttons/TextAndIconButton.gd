tool
extends Button

export(Texture) var texture setget set_image
export var button_text = "" setget set_button_text

	
	
func set_image(value):
	texture = value
	$HBoxContainer/TextureRect.texture = texture

func set_button_text(value):
	button_text = value
	$HBoxContainer/Label.text = value
