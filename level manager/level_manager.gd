extends Node2D

onready var Puppy = preload("res://puppy/puppy.tscn")


var levels = [
	preload("res://levels/hacked_level.tscn"),
	]

var level_index = 0


var current_level
var puppies = []
var number_of_puppies


func _ready():
	Bus.connect("puppy.collected", self, "_on_puppy_collected")
	Bus.connect("puppies.delivered", self, "_on_puppies_delivered")


func _on_puppy_collected(puppy):
	if not puppy in puppies:
		puppies.append(puppy)


func _on_puppies_delivered():
	var delivered = puppies.size()
	if delivered > 0:
		Bus.emit_signal("puppies.saved", delivered)
		number_of_puppies -= delivered
		puppies.clear()
		if number_of_puppies <= 0:
			end_level()


func start_game():
	level_index = 0
	start_level()


func start_level():
	puppies.clear()
	for c in get_children():
		c.queue_free()
	position = Vector2()
	current_level = levels[level_index].instance()
	add_child(current_level)
	var puppies_layer = current_level.find_node("puppies layer")
	number_of_puppies = puppies_layer.get_child_count()
	Bus.emit_signal("level.started")


func restart_level():
	# Respawn collected but undelivered puppies.
	var parent = current_level.find_node("puppies layer")
	for pos in puppies:
		var p = Puppy.instance()
		parent.add_child(p)
		p.position = pos
	puppies.clear()
	Bus.emit_signal("level.started")


func end_level():
	level_index += 1
	if level_index >= levels.size():
		# TODO: win the game if you complete all levels.
		level_index = 0
	start_level()


func end_game():
	puppies.clear()
	for c in get_children():
		c.queue_free()
