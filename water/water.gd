extends Area2D


func _on_water_body_enter(body):
	if body.has_method("_on_entered_water"):
		body._on_entered_water()
