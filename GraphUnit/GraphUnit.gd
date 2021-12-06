extends PanelContainer
class_name GraphUnit

signal UnitChanged
signal InputPressed
signal OutputPressed

export var inputCount:int setget SetInputs
export var outputCount:int setget SetOutputs

onready var inputParent: = $HBoxContainer/InputParent
onready var outputParent: = $HBoxContainer/OutputParent

var connectorScene:PackedScene = preload("res://UnitConnector/Connector.tscn")
var isDragged: = false
var inputs:Array = []
var outputs:Array = []
var connections:Array = []

func SetInputs(value:int)->void:
	if !is_inside_tree():
		inputCount = value
		return
	if inputCount < value:
		for i in (value - inputCount):
			var inst:Button = connectorScene.instance()
			inputParent.add_child(inst)
# warning-ignore:return_value_discarded
			inst.connect("pressed", self, "InputPressed", [inst, inputs.size()])
			inputs.append(inst)
			inst.modulate = Color(randf(), randf(), randf())	############# TEST
	elif inputCount > value:
		for i in (inputCount - value):
			inputs.pop_back().queue_free()
	inputCount = value

func SetOutputs(value:int)->void:
	if !is_inside_tree():
		outputCount = value
		return
	if outputCount < value:
		for i in (value - outputCount):
			var inst:Button = connectorScene.instance()
			outputParent.add_child(inst)
# warning-ignore:return_value_discarded
			inst.connect("pressed", self, "OutputPressed", [inst, outputs.size()])
			outputs.append(inst)
			inst.modulate = Color(randf(), randf(), randf())	############# TEST
	elif outputCount > value:
		for i in (outputCount - value):
			outputs.pop_back().queue_free()
	outputCount = value

func _ready()->void:
	var inC = inputCount
	var outC = outputCount
	inputCount = 0
	outputCount = 0
	SetInputs(inC)
	SetOutputs(outC)

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

func InputPressed(_connector:Button, index:int)->void:
	emit_signal("InputPressed", self, index)

func OutputPressed(_connector:Button, index:int)->void:
	emit_signal("OutputPressed", self, index)

func Connected(data:Dictionary)->void:
	connections.append(data)
	update()
	print(data)

func _draw()->void:
#	if connections.size() > 0:
#		draw_line(self.rect_position, connections[0].rect_position, Color.bisque, 1)
	pass
