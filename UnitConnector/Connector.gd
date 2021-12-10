extends Button
class_name Connector

signal Disconnect

func _gui_input(event:InputEvent)->void:
	if event is InputEventMouseButton:
		if event.button_index == 2 && !event.pressed:
			emit_signal("Disconnect")
