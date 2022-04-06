extends "GraphUnit.gd"
class_name GraphUnitNaked

signal UnitDragged

export var unitName:String = "default" setget SetName
export var unitID:int = -1 setget SetID

var wasDragged:bool = false

func _ready()->void:
	handleGUIinBase = false
	SetInputs(inputCount)
	SetOutputs(outputCount)
#	UnitName.text = unitName
	
func SetName(value:String)->void:
	if !value.empty():
		unitName = value

func SetID(value:int)->void:
	if value >= 0:
		unitID = value

# Adding place where Unit exists, probs should be done in ready
func SetBoard(_board)->void:
	UnitBoardEditor = _board
	UnitName.text = unitName

# has to be single, or uses first
func TriggerConnection()->void:
	if outputs.size() > 0:
		emit_signal("OutputPressed", self, 0)
	elif inputs.size() > 0:
		emit_signal("InputPressed", self, 0)

func _gui_input(event:InputEvent)->void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.pressed && !isSelected:
				isSelected = true
				parent.move_child(self, parent.get_child_count() -1)
				wasDragged = false
#				emit_signal("UnitDragged", self)
			if !event.pressed && isSelected:
				isSelected = false
				emit_signal("UnitDragged", null, Vector2.ZERO)
#				if wasDragged == true:
#					TriggerConnection()
	elif event is InputEventMouseMotion && isSelected:
		wasDragged = true
		emit_signal("UnitDragged", self, rect_position + event.position)
		TriggerConnection()
