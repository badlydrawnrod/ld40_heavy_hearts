extends Node2D

onready var player = get_node("sample player")
onready var tunes = get_node("stream player")


func _ready():
	tunes.play()
	Bus.connect("player.popped", self, "_on_player_popped")
	Bus.connect("player.killed", self, "_on_player_killed")
	Bus.connect("enemy.popped", self, "_on_enemy_popped")
	Bus.connect("puppy.collected", self, "_on_puppy_collected")
	Bus.connect("puppies.saved", self, "_on_puppies_saved")


var player_popped = [ "no" ]

func _on_player_popped():
	var n = (randi() >> 1) % player_popped.size()
	player.play(player_popped[n])


var killed = [ "disaster", "waah" ]

func _on_player_killed():
	var n = (randi() >> 1) % killed.size()
	player.play(killed[n])


var popped = [ "my_balloon", "gotcha", "bye" ]

func _on_enemy_popped():
	var n = (randi() >> 1) % popped.size()
	player.play(popped[n])


var collected = [ "mama" ]

func _on_puppy_collected(x):
	var n = (randi() >> 1) % collected.size()
	player.play(collected[n])


var delivered = [ "daddy", "mummy" ]

func _on_puppies_saved(x):
	var n = (randi() >> 1) % delivered.size()
	player.play(delivered[n])
