extends "GraphUnit.gd"
class_name GraphUnitNaked

signal UnitDragged

export var unitName:String = "default" setget SetName
export var unitID:int = -1 setget SetID

func _ready()->void:
	handleGUIinBase = false
	SetInputs(inputCount)
	SetOutputs(outputCount)
#	UnitName.text = unitName
	
func SetName(value:String)->void:
	if value.is_valid_identifier():
		unitName = value

func SetID(value:int)->void:
	if value >= 0:
		unitID = value

# Adding place where Unit exists, probs should be done in ready
func SetBoard(_board)->void:
	UnitBoardEditor = _board
	UnitName.text = unitName


func _gui_input(event:InputEvent)->void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.pressed && !isDragged:
				isDragged = true
				parent.move_child(self, parent.get_child_count() -1)
#				emit_signal("UnitDragged", self)
			if !event.pressed && isDragged:
				isDragged = false
				emit_signal("UnitDragged", null, Vector2.ZERO)
	elif event is InputEventMouseMotion && isDragged:
		emit_signal("UnitDragged", self, self.rect_global_position + event.position)
		if outputs.size() > 0:
			emit_signal("OutputPressed", self, 0)
