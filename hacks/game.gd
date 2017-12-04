extends Node2D

onready var camera = get_node("camera")


func _ready():
	Bus.connect("player.moved", self, "_on_player_moved")


func _on_player_moved(pos):
	pass
#	var camera_pos = camera.get_pos()
#	var desired_y = pos.y - 96
#	if desired_y >= 0:
#		desired_y = 0
#	camera_pos.y = lerp(camera_pos.y, desired_y, 0.1)
#	camera.set_pos(camera_pos)
