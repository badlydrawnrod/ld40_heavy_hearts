extends Node2D

export var shake_duration = 0.5
export var shake_start_size = 2
export var shake_end_size = 1

onready var Puppy = preload("res://puppy/puppy.tscn")


var levels = [
	preload("res://levels/hacked_level.tscn"),
	]

var level_index = 0


var current_level
var puppies = []
var number_of_puppies
var is_shaking


func _ready():
	Bus.connect("player.moved", self, "_on_player_moved")
	Bus.connect("puppy.collected", self, "_on_puppy_collected")
	Bus.connect("puppies.delivered", self, "_on_puppies_delivered")
	Bus.connect("player.popped", self, "shake_screen")
	Bus.connect("enemy.popped", self, "shake_screen")


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
	set_pos(Vector2())
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
		p.set_pos(pos)
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


func _on_player_moved(pos):
	var camera_pos = get_pos()
	var desired_y = -pos.y + 96
	if desired_y < 0:
		desired_y = 0
	camera_pos.y = lerp(camera_pos.y, desired_y, 0.1)
	set_pos(camera_pos)


func shake_screen():
	if is_shaking:
		return
	is_shaking = true

	var remaining = shake_duration
	var fixed_process_delta_time = get_fixed_process_delta_time()
	var steps = remaining / fixed_process_delta_time
	var size_delta = (shake_start_size - shake_end_size) / steps
	var size = shake_start_size

	var original = get_pos()
	
	while remaining > 0:
		var pos = original
		pos.x += rand_range(-size, size)
		pos.y += rand_range(-size, size)
		set_pos(pos)
		remaining -= fixed_process_delta_time
		size -= size_delta
		yield(get_tree(), "fixed_frame")

	set_pos(original)
	
	is_shaking = false
