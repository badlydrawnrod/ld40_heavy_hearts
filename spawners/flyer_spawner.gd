extends Position2D

export var initial_spawn_delay = 5
export var spawn_delay = 60
export var max_flyers = 5

var flyers

var Flyer = preload("res://enemies/flyer/flyer.tscn")

onready var timer = get_node("timer")
onready var sprite = get_node("sprite")


func _ready():
	Bus.connect("level.started", self, "_on_level_started")


func _on_level_started():
	timer.set_active(false)
	timer.stop()
	timer.set_wait_time(initial_spawn_delay)
	timer.set_active(true)
	timer.start()
	flyers = 0
	sprite.hide()


func _on_timer_timeout():
	timer.stop()
	if flyers < max_flyers:
		flyers += 1
		spawn_flyer()


func spawn_flyer():
	
	var tween = get_node("tween")
	sprite.show()
	tween.interpolate_property(sprite, "frame", 0, 3, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_complete")
	sprite.hide()
	
	# Spawn a flyer.
	var flyer = Flyer.instance()
	flyer.set_pos(get_pos())
	get_parent().add_child(flyer)
	
	timer.set_wait_time(spawn_delay)
	timer.start()
