extends Node2D


func _ready():
	$tunes.play()
	Bus.connect("player.popped", self, "_on_player_popped")
	Bus.connect("player.killed", self, "_on_player_killed")
	Bus.connect("enemy.popped", self, "_on_enemy_popped")
	Bus.connect("puppy.collected", self, "_on_puppy_collected")
	Bus.connect("puppies.saved", self, "_on_puppies_saved")


func _on_player_popped():
	$no.play()


func _on_player_killed():
	var n = (randi() >> 1) % 2
	if n == 0:
		$disaster.play()
	else:
		$waah.play()


func _on_enemy_popped():
	var n = (randi() >> 1) % 3
	if n == 0:
		$my_balloon.play()
	elif n == 1:
		$gotcha.play()
	else:
		$bye.play()


func _on_puppy_collected(x):
	$mama.play()


func _on_puppies_saved(x):
	var n = (randi() >> 1) % 2
	if n == 0:
		$daddy.play()
	else:
		$mummy.play()
