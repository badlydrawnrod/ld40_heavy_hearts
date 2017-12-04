extends VBoxContainer


func _on_start_button_pressed():
	Bus.emit_signal("game.start")
