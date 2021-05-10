extends Node2D

onready var DirectionTrack = true

func _flip_sprite():
	if DirectionTrack == true :
		$SlashNode.scale.x = -1
		DirectionTrack = false
	if DirectionTrack == false:
		$SlashNode.scale.x = 1
		DirectionTrack = true
		
