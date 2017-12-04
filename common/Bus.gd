extends Node

const DEBUG = false


var signals = [
	"game.start",
	"level.started",
	"player.moved",
	"player.killed",
	"player.popped",
	"enemy.killed",
	"enemy.popped",
	"puppy.collected",
	"puppies.delivered",
	"puppies.saved",
	"score.changed",
	"high_score.changed",
	"lives.changed"
]


func _ready():
	for s in signals:
		add_user_signal(s)

	if DEBUG:
		for s in signals:
			var args = [s]
			print("Bus: adding signal: ", s)
			connect(s, self, "show_signal", args)


func show_signal(a=null, b=null, c=null, d=null, e=null, f=null):
	var args = []
	for s in [a, b, c, d, e, f]:
		if s != null:
			args.append(s)

	var name = args.back()
	args.pop_back()
	args.push_front(name)
	print("Bus: ", args)
