extends KinematicBody2D

const RIGHT = Vector2(128, 0)
const GRAVITY = Vector2(0, 128)
const CARRYING_DRAG = Vector2(0, 96)
const THRUST = Vector2(0, -96)
const FLOOR_NORMAL = Vector2(0, -1)

onready var sprite = get_node("sprite")
onready var balloon_area = get_node("balloon area")
onready var particles = get_node("particles")
var collected_puppy = preload("res://puppy/collected_puppy.tscn")

export var horizontal_damping = 0.1
export var max_carrying = 6

var velocity = Vector2()
var was_input_thrust = false
var carrying = 0
var extents
var left
var right
var facing = 1
var balloons = 2


func copy_state(src):
	horizontal_damping = src.horizontal_damping
	max_carrying = src.max_carrying
	velocity = Vector2(src.velocity)
	was_input_thrust = src.was_input_thrust
	carrying = src.carrying
	facing = src.facing
	balloons = src.balloons


func _ready():
	Bus.connect("level.started", self, "_on_level_started")
	
	set_fixed_process(true)

	# Get the underlying shape's extents.
	var shape = get_node("shape")
	var extent_shape = shape.get_shape()
	extents = extent_shape.get_extents()

	# Get viewport left and right.
	var vp = get_viewport()
	var r = vp.get_rect()
	left = r.pos.x
	right = r.end.x

	# Add the puppies and balloons.
	for i in range(carrying):
		add_puppy(i)
	for i in range(balloons):
		add_balloon(i)

	if facing > 0:
		sprite.set_flip_h(false)
		balloon_area.set_scale(Vector2(1, 1))
		facing = 1
	else:
		sprite.set_flip_h(true)
		balloon_area.set_scale(Vector2(-1, 1))
		facing = -1


func _fixed_process(delta):
	# Where were we before we moved.
	var last_pos = get_pos()

	# Read the inputs.
	var input_right = Input.is_action_pressed("player_right")
	var input_left = Input.is_action_pressed("player_left")
	var input_thrust = Input.is_action_pressed("player_thrust")

	# If we have any balloons attached, then allow the inputs to take effect.
	var input_velocity
	if balloons > 0:
		var input_velocity = RIGHT * (input_right - input_left)

		velocity.x = lerp(velocity.x, input_velocity.x, horizontal_damping)
		if input_velocity.x > 0 and facing < 0:
			sprite.set_flip_h(false)
			balloon_area.set_scale(Vector2(1, 1))
			facing = 1
		elif input_velocity.x < 0 and facing > 0:
			sprite.set_flip_h(true)
			balloon_area.set_scale(Vector2(-1, 1))
			facing = -1

		if input_thrust and not was_input_thrust:
			velocity.y = THRUST.y
			particles.set_emitting(true)
		was_input_thrust = input_thrust

	velocity += GRAVITY * delta
	velocity += GRAVITY * (1 + (1 * carrying/max(1, balloons))) * delta

	velocity = move_and_slide(velocity, FLOOR_NORMAL)

	var pos = get_pos()
	Bus.emit_signal("player.moved", pos)

	# Check if we're wrapping the screen horizontally.
	if pos.x - extents.x < left:
		if last_pos.x - extents.x >= left:
			# When the sprite's right edge goes off the left side of the screen then it is duplicated on the right.
			Factory.clone_player(self, pos + Vector2(right - left, 0))
		if pos.x + extents.x < left:
			# When the sprite's left edge goes off the left side of the screen then it is deleted.
			queue_free()
	elif pos.x + extents.x >= right:
		if last_pos.x + extents.x < right:
			# When the sprite's left edge goes off the right side of the screen then it is duplicated on the right.
			Factory.clone_player(self, pos - Vector2(right - left, 0))
		if pos.x - extents.x >= right:
			# When the sprite's left edge goes off the left side of the screen then it is deleted.
			queue_free()


func _on_collect_puppy(body):
	if carrying < max_carrying:
		Bus.emit_signal("puppy.collected", body.get_pos())
		body.queue_free()
		add_puppy(carrying)
		carrying += 1


func add_puppy(i):
	var p = collected_puppy.instance()
	var angle = (i)
	if angle % 2 == 0:
		angle = -angle-1
	angle *= PI / 9
	angle += PI / 2
	p.set_pos(Vector2(cos(angle) * 16, sin(angle) * 20))
	var mount = get_node("puppy mount")
	mount.add_child(p)


func _on_balloon_area_body_enter(body):
	if balloons == 0:
		return
	Bus.emit_signal("player.popped")
	balloons -= 1
	remove_balloon(balloons)
	if balloons == 0:
		set_collision_mask(1024)	# Collide with water only.
		set_layer_mask(0)


func _on_collector_area_enter(area):
	var mount = get_node("puppy mount")
	for c in mount.get_children():
		c.queue_free()
	carrying = 0
	Bus.emit_signal("puppies.delivered")


func add_balloon(i):
	get_node("balloon area/mounts").get_child(i).show()


func remove_balloon(i):
	get_node("balloon area/mounts").get_child(i).hide()


func _on_entered_water():
	Bus.emit_signal("player.killed")


func _on_level_started():
	queue_free()
