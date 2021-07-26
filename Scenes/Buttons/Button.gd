extends Button


var selected = false
var active = false setget set_active


func select():
	self.active = true
	selected = true
	
func unselect():
	self.active = false
	selected = false


func _on_IconButton_mouse_entered():
	if !selected:
		self.active = true


func _on_IconButton_mouse_exited():
	if !selected:
		self.active = false


func set_active(value):
	active = value
	$ActiveRect.visible = active
