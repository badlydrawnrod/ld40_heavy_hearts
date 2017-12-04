extends Node2D


onready var level_manager = get_node("level manager")

export var death_delay_time = 3

var score
var lives
var high_score = 100

var is_handling_kill

func _ready():
	Bus.connect("game.start", self, "_on_game_start")
	Bus.connect("player.killed", self, "_on_player_killed")
	Bus.connect("enemy.killed", self, "_on_enemy_killed")
	Bus.connect("puppies.saved", self, "_on_puppies_saved")
	set_high_score(high_score)


func _on_game_start():
	get_node("gui/main menu").hide()
	get_node("gui/game gui").show()
	set_score(0)
	set_lives(3)

	is_handling_kill = false

	level_manager.start_game()


func _on_game_over():
	get_node("gui/main menu").show()
	get_node("gui/game gui").hide()


func _on_player_killed():
	# Sometimes the player can get killed multiple times in one tick.
	if is_handling_kill:
		return
	is_handling_kill = true

	# Create a timer.
	var t = Timer.new()
	t.set_wait_time(death_delay_time)
	t.set_one_shot(true)
	add_child(t)
	t.start()

	# Wait for the timeout signal.
	yield(t, "timeout")

	# Remove the timer.
	t.queue_free()

	is_handling_kill = false
	set_lives(lives - 1)
	if lives > 0:
		level_manager.restart_level()
	else:
		level_manager.end_game()
		_on_game_over()


func _on_enemy_killed(enemy):
	set_score(score + enemy.score)


func _on_puppies_saved(count):
	set_score(score + 100 * count * count)
	
	
func set_score(new_score):
	score = new_score
	Bus.emit_signal("score.changed", score)
	if score > high_score:
		set_high_score(score)


func set_high_score(new_score):
	high_score = new_score
	Bus.emit_signal("high_score.changed", high_score)


func set_lives(new_lives):
	lives = new_lives
	Bus.emit_signal("lives.changed", lives)
