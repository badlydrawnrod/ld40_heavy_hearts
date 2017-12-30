extends Position2D

var Player = preload("res://player/player.tscn")

export var delay = 0.5

onready var sprite = get_node("sprite")


func _ready():
	Bus.connect("level.started", self, "_on_level_started")


func _on_level_started():
	sprite.hide()
	Bus.emit_signal("player.moved", position)

	# Create a timer.
	var t = Timer.new()
	t.wait_time = delay
	t.one_shot = true
	add_child(t)
	t.start()

	# Wait for the timeout signal.
	yield(t, "timeout")
	t.queue_free()

	var tween = get_node("tween")
	sprite.show()
	tween.interpolate_property(sprite, "frame", 0, 3, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	sprite.hide()

	# Spawn the player.
	var player = Player.instance()
	player.position = position
	get_parent().add_child(player)
