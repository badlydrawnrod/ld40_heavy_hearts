extends HBoxContainer

onready var game = get_node("/root/game")
onready var score = get_node("score")
onready var high_score = get_node("high score")
onready var lives = get_node("lives")


func _ready():
	Bus.connect("score.changed", self, "_on_score_changed")
	Bus.connect("high_score.changed", self, "_on_high_score_changed")
	Bus.connect("lives.changed", self, "_on_lives_changed")


func _on_score_changed(new_score):
	score.set_text("%06d" % new_score)


func _on_high_score_changed(new_score):
	high_score.set_text("%06d" % new_score)


func _on_lives_changed(new_lives):
	lives.set_text("%d" % new_lives)
