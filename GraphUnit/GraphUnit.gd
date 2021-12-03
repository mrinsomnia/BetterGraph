extends TextureRect

signal UnitChanged

var editor:Node
var isDragged: = false


func _ready()->void:
# warning-ignore:return_value_discarded
	connect("UnitChanged", owner, "UnitChanged")
	editor = owner
	editor.AddUnit(self)

func _exit_tree()->void:
	editor.RemoveUnit(self)

func _gui_input(event:InputEvent)->void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.pressed && !isDragged:
				isDragged = true
			if !event.pressed && isDragged:
				isDragged = false
	elif event is InputEventMouseMotion && isDragged:
		rect_position += event.relative
		emit_signal("UnitChanged", rect_position, rect_size)
