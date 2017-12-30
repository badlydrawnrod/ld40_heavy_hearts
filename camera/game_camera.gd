extends Node2D

export var shake_duration = 0.5
export var shake_start_size = 4
export var shake_end_size = 2

var is_shaking


func _ready():
	Bus.connect("player.moved", self, "_on_player_moved")
	Bus.connect("player.popped", self, "shake_screen")
	Bus.connect("enemy.popped", self, "shake_screen")
	is_shaking = false


func _on_player_moved(pos):
	var ct = get_viewport().get_canvas_transform()
	var camera_pos = ct.origin
	var desired_y = -pos.y + 96
	if desired_y < 0:
		desired_y = 0
	camera_pos.y = lerp(camera_pos.y, desired_y, 0.1)
	ct.origin = camera_pos
	get_viewport().set_canvas_transform(ct)


func shake_screen():
	if is_shaking:
		return
	is_shaking = true

	var remaining = shake_duration
	var fixed_process_delta_time = get_physics_process_delta_time()
	var steps = remaining / fixed_process_delta_time
	var size_delta = (shake_start_size - shake_end_size) / steps
	var size = shake_start_size

	var ct = get_viewport().get_canvas_transform()
	var original = ct.origin

	while remaining > 0:
		var pos = original
		pos.x += rand_range(-size, size)
		pos.y += rand_range(-size, size)
		ct.origin = pos
		get_viewport().set_canvas_transform(ct)
		remaining -= fixed_process_delta_time
		size -= size_delta
		yield(get_tree(), "physics_frame")

	ct.origin = original
	get_viewport().set_canvas_transform(ct)

	is_shaking = false
