tool
extends Button

export(Texture) var texture setget set_image
export var button_text = "" setget set_button_text


var selected = false
var active = false setget set_active
	
	
func set_image(value):
	texture = value
	$HBoxContainer/TextureRect.texture = texture

func set_button_text(value):
	button_text = value
	$HBoxContainer/Label.text = value


func select():
	self.active = true
	selected = true
	
func unselect():
	self.active = false
	selected = false


func _on_TextAndIconButton_mouse_entered():
	if !selected:
		self.active = true


func _on_TextAndIconButton_mouse_exited():
	if !selected:
		self.active = false


func set_active(value):
	active = value
	$ActiveRect.visible = active
