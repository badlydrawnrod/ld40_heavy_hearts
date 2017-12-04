extends KinematicBody2D

const FLOOR_NORMAL = Vector2(0, -1)

const GRAVITY = Vector2(0, 128)

enum { BALLOONING, PARACHUTING, FALLING }

export var RIGHT = Vector2(96, 0)
export var THRUST = Vector2(0, -96)
export var horizontal_damping = 0.05
export var score = 100

onready var particles = get_node("particles")

var velocity = Vector2()
var extents
var left
var right
var time = 0
var thrust_interval = 1.5
var thrust_time = thrust_interval
var facing = 1
var state = BALLOONING


func copy_state(src):
	velocity = Vector2(src.velocity)
	time = src.time
	thrust_interval = src.thrust_interval
	thrust_time = src.thrust_time
	facing = src.facing
	state = src.state


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
	
	if state == BALLOONING:
		add_balloon()


func _fixed_process(delta):
	# Where were we before we moved.
	var last_pos = get_pos()

	# Read the inputs.
	var input_right = Input.is_action_pressed("player_right")
	var input_left = Input.is_action_pressed("player_left")

	var input_velocity
	if state == BALLOONING:
		input_velocity = RIGHT * facing
	else:
		input_velocity = Vector2()
	velocity.x = lerp(velocity.x, input_velocity.x, horizontal_damping)

	time += delta
	if state == BALLOONING:
		if time >= thrust_time:
			particles.set_emitting(true)
			velocity.y = THRUST.y
			if last_pos.y >= 240:
				thrust_time = time + thrust_interval * 0.5
			elif last_pos.y < -240:
				thrust_time = time + thrust_interval * 1.5
			else:
				thrust_time = time + thrust_interval
			if rand_range(0, 100) < 30:
				facing = -facing

	velocity += GRAVITY * delta
	if state == FALLING:
		velocity += GRAVITY * delta

	velocity = move_and_slide(velocity, FLOOR_NORMAL)

	# Check if we're wrapping the screen horizontally.
	var pos = get_pos()
	if pos.x - extents.x < left:
		if last_pos.x - extents.x >= left:
			# When the sprite's right edge goes off the left side of the screen then it is duplicated on the right.
			Factory.clone_flyer(self, pos + Vector2(right - left, 0))
		if pos.x + extents.x < left:
			# When the sprite's left edge goes off the left side of the screen then it is deleted.
			queue_free()
	elif pos.x + extents.x >= right:
		if last_pos.x + extents.x < right:
			# When the sprite's left edge goes off the right side of the screen then it is duplicated on the right.
			Factory.clone_flyer(self, pos - Vector2(right - left, 0))
		if pos.x - extents.x >= right:
			# When the sprite's left edge goes off the left side of the screen then it is deleted.
			queue_free()


func _on_balloon_area_body_enter(body):
	if state != BALLOONING:
		return
	Bus.emit_signal("enemy.popped")
	# This should really be parachuting, but I'm dropping scope.
	state = FALLING
	set_collision_mask(1024)	# Collide with water only.
	set_layer_mask(0)
	
	remove_balloon()
	

func remove_balloon():
	for c in get_node("balloon area/mounts").get_children():
		c.hide()


func add_balloon():
	for c in get_node("balloon area/mounts").get_children():
		c.show()


func _on_entered_water():
	Bus.emit_signal("enemy.killed", self)
	
	# Create a timer.
	var t = Timer.new()
	t.set_wait_time(0.5)
	t.set_one_shot(true)
	add_child(t)
	t.start()

	# Wait for the timeout signal.
	yield(t, "timeout")
	
	queue_free()


func _on_level_started():
	queue_free()
