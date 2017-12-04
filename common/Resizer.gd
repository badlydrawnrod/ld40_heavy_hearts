extends Node

export var scale = 2
export var centre_window = true


func _ready():
	if not OS.is_window_fullscreen():
		if Globals.get("display/stretch_mode") == "viewport" and not OS.is_window_fullscreen():
			# Size the window to accommodate multiples of the base resolution.
			var window_size = OS.get_window_size()
			window_size *= scale
			OS.set_window_size(window_size)

		# Centre the window if required.
		if centre_window:
			# Centre the window on the current screen.
			var screen_size = OS.get_screen_size(OS.get_current_screen())
			var window_pos = (screen_size - OS.get_window_size()) / 2
			OS.set_window_position(window_pos)
