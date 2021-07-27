extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _process(delta):
	$AnimatedSprite.global_position = get_viewport().size / 2


func show():
	$AnimationPlayer.play("show")
	
func hide():
	$AnimationPlayer.play("hide")
	yield($AnimationPlayer, "animation_finished")
