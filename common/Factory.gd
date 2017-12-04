extends Node


var Flyer = preload("res://enemies/flyer/flyer.tscn")
var Player = preload("res://player/player.tscn")


func clone_flyer(src, pos):
	var dst = Flyer.instance()
	dst.set_pos(pos)
	dst.copy_state(src)
	src.get_parent().add_child(dst)


func clone_player(src, pos):
	var dst = Player.instance()
	dst.set_pos(pos)
	dst.copy_state(src)
	src.get_parent().add_child(dst)
