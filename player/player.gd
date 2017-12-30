extends KinematicBody2D

const RIGHT = Vector2(128, 0)
const GRAVITY = Vector2(0, 128)
const CARRYING_DRAG = Vector2(0, 96)
const THRUST = Vector2(0, -96)
const FLOOR_NORMAL = Vector2(0, -1)

var collected_puppy = preload("res://puppy/collected_puppy.tscn")

export var horizontal_damping = 0.1
export var max_carrying = 6

var velocity = Vector2()
var was_input_thrust = false
var carrying = 0
var extents
var left
var right
var width
var facing = 1
var balloons = 2


func _ready():
	Bus.connect("level.started", self, "_on_level_started")

	set_physics_process(true)

	var shape = get_child(0)
	var extent_shape = shape.get_shape()
	extents = extent_shape.get_extents()

	# Get viewport left and right.
	var vp = get_viewport()
	var r = vp.get_visible_rect()
	left = r.position.x
	right = r.end.x
	width = right - left

	for i in range(get_child_count()):
		var c = get_child(i)
		c.position = Vector2(i * width, 0)

		# Add the puppies and balloons.
		for j in range(carrying):
			add_puppy(c, j)
		for j in range(balloons):
			add_balloon(c, j)

		if facing > 0:
			c.get_node("sprite").set_flip_h(false)
			c.get_node("balloon area").set_scale(Vector2(1, 1))
			facing = 1
		else:
			c.get_node("sprite").set_flip_h(true)
			c.get_node("balloon area").set_scale(Vector2(-1, 1))
			facing = -1


func _physics_process(delta):
	# Where were we before we moved.
	var last_pos = position

	# Read the inputs.
	var input_right = Input.is_action_pressed("player_right")
	var input_left = Input.is_action_pressed("player_left")
	var input_thrust = Input.is_action_pressed("player_thrust")

	# If we have any balloons attached, then allow the inputs to take effect.
	var input_velocity = Vector2()
	if balloons > 0:
		if input_right and not input_left:
			input_velocity = RIGHT
		elif input_left and not input_right:
			input_velocity = -RIGHT

		velocity.x = lerp(velocity.x, input_velocity.x, horizontal_damping)
		if input_velocity.x > 0 and facing < 0:
			for c in get_children():
				c.get_node("sprite").set_flip_h(false)
				c.get_node("balloon area").set_scale(Vector2(1, 1))
			facing = 1
		elif input_velocity.x < 0 and facing > 0:
			for c in get_children():
				c.get_node("sprite").set_flip_h(true)
				c.get_node("balloon area").set_scale(Vector2(-1, 1))
			facing = -1

		if input_thrust and not was_input_thrust:
			velocity.y = THRUST.y
			for c in get_children():
				c.get_node("particles").set_emitting(true)

		was_input_thrust = input_thrust

	velocity += GRAVITY * delta
	velocity += GRAVITY * (1 + (1 * carrying/max(1, balloons))) * delta

	velocity = move_and_slide(velocity, FLOOR_NORMAL)
	Wrapper.wrap_horizontal(self, last_pos, width, extents, left, right)

	Bus.emit_signal("player.moved", position)


func _on_collect_puppy(body):
	if carrying < max_carrying:
		Bus.emit_signal("puppy.collected", body.position)
		body.queue_free()
		add_puppy(carrying)
		carrying += 1


func add_puppy(i):
	for c in get_children():
		var p = collected_puppy.instance()
		var angle = (i)
		if angle % 2 == 0:
			angle = -angle-1
		angle *= PI / 9
		angle += PI / 2
		p.position = Vector2(cos(angle) * 16, sin(angle) * 20)
		var mount = c.get_node("puppy mount")
		mount.add_child(p)


func _on_balloon_area_body_enter(body):
	if balloons == 0:
		return
	Bus.emit_signal("player.popped")
	balloons -= 1
	for child in get_children():
		remove_balloon(child, balloons)
	if balloons == 0:
		collision_mask = 1024		# Collide with water only.
		collision_layer = 0


func _on_collector_area_enter(area):
	for child in get_children():
		var mount = child.get_node("puppy mount")
		for c in mount.get_children():
			c.queue_free()
	carrying = 0
	Bus.emit_signal("puppies.delivered")


func add_balloon(c, i):
	c.get_node("balloon area/mounts").get_child(i).show()


func remove_balloon(c, i):
	c.get_node("balloon area/mounts").get_child(i).hide()


func _on_entered_water():
	Bus.emit_signal("player.killed")


func _on_level_started():
	queue_free()
