extends Control

func _ready():
	_on_Q0_pressed()
	
	
func close_all():
	for c in $VBoxContainer/Control/HBoxContainer/Answers.get_children():
		c.visible = false
	
	for q in $VBoxContainer/Control/HBoxContainer/Questions.get_children():
		q.unselect()
		

func _on_Q1_pressed():
	close_all()
	$VBoxContainer/Control/HBoxContainer/Questions/Q1.select()
	$VBoxContainer/Control/HBoxContainer/Answers/A1.visible = true
	

func _on_Q2_pressed():	
	close_all()
	$VBoxContainer/Control/HBoxContainer/Questions/Q2.select()
	$VBoxContainer/Control/HBoxContainer/Answers/A2.visible = true


func _on_Q3_pressed():
	close_all()
	$VBoxContainer/Control/HBoxContainer/Questions/Q3.select()
	$VBoxContainer/Control/HBoxContainer/Answers/A3.visible = true


func _on_Q4_pressed():
	close_all()
	$VBoxContainer/Control/HBoxContainer/Questions/Q4.select()
	$VBoxContainer/Control/HBoxContainer/Answers/A4.visible = true


func _on_Q0_pressed():
	close_all()
	$VBoxContainer/Control/HBoxContainer/Questions/Q0.select()
	$VBoxContainer/Control/HBoxContainer/Answers/A0.visible = true

func _on_Q5_pressed():
	close_all()
	$VBoxContainer/Control/HBoxContainer/Questions/Q5.select()
	$VBoxContainer/Control/HBoxContainer/Answers/A5.visible = true
