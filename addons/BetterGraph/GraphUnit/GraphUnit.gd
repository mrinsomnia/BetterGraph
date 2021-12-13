extends PanelContainer
class_name GraphUnit

signal UnitChanged
signal InputPressed
signal OutputPressed
signal Disconnect
signal ConnectionsRemoved
signal DrawConnections

export var inputCount:int setget SetInputs
export var outputCount:int setget SetOutputs
export var inputParentPath:NodePath
export var outputParentPath:NodePath
export var connectorScene:PackedScene = preload("res://addons/BetterGraph/UnitConnector/Connector.tscn")

onready var inputParent: = get_node(inputParentPath)
onready var outputParent: = get_node(outputParentPath)
onready var parent:Node = get_parent()

var isDragged: = false
var inputs:Array = []
var outputs:Array = []
var connectionsIn:Dictionary = {}	#data list array by output key
var connectionsOut:Dictionary = {}	#data list array by output key

func SetInputs(value:int)->void:
	if value < 0:
		return
	if !is_inside_tree():
		inputCount = value
		return
	if inputCount < value:
		for i in (value - inputCount):
			var inst:Button = connectorScene.instance()
			inputParent.add_child(inst)
# warning-ignore:return_value_discarded
			inst.connect("pressed", self, "InputPressed", [inst, inputs.size()])
# warning-ignore:return_value_discarded
			inst.connect("Disconnect", self, "InputDisconnected", [inputs.size()])
# warning-ignore:return_value_discarded
			inst.connect("tree_exited", self, "InputRemoved", [inputs.size()])
			inputs.append(inst)
			inst.modulate = Color(randf(), randf(), randf())	############# TEST
	elif inputCount > value:
		for i in (inputCount - value):
			inputs.pop_back().queue_free()
	inputCount = value

func SetOutputs(value:int)->void:
	if value < 0:
		return
	if !is_inside_tree():
		outputCount = value
		return
	if outputCount < value:
		for i in (value - outputCount):
			var inst:Button = connectorScene.instance()
			outputParent.add_child(inst)
# warning-ignore:return_value_discarded
			inst.connect("pressed", self, "OutputPressed", [inst, outputs.size()])
# warning-ignore:return_value_discarded
			inst.connect("Disconnect", self, "OutputDisconnected", [outputs.size()])
# warning-ignore:return_value_discarded
			inst.connect("tree_exited", self, "OutputRemoved", [outputs.size()])
			outputs.append(inst)
			inst.modulate = Color(randf(), randf(), randf())	############# TEST
	elif outputCount > value:
		for i in (outputCount - value):
			outputs.pop_back().queue_free()
			# TO-DO: check if connections exists
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
				parent.move_child(self, parent.get_child_count() -1)
			if !event.pressed && isDragged:
				isDragged = false
	elif event is InputEventMouseMotion && isDragged:
		rect_position += event.relative
		emit_signal("UnitChanged", self, rect_position, rect_size)


func InputPressed(_connector:Button, index:int)->void:
	emit_signal("InputPressed", self, index)

func OutputPressed(_connector:Button, index:int)->void:
	emit_signal("OutputPressed", self, index)


func InputDisconnected(index:int)->void:
	if !connectionsIn.has(index):
		return
	if connectionsIn[index].empty():
		return
	var data:Dictionary = connectionsIn[index].pop_back()
	var list:Array = data.unitOut.connectionsOut[data.output]
	for i in list.size():
		if list[i] == data:
			data.unitOut.connectionsOut[data.output].remove(i)
			break
	emit_signal("Disconnect", data)

func OutputDisconnected(index:int)->void:
	if !connectionsOut.has(index):
		return
	if connectionsOut[index].empty():
		return
	var data:Dictionary = connectionsOut[index].pop_back()
	var list:Array = data.unitIn.connectionsIn[data.input]
	for i in list.size():
		if list[i] == data:
			data.unitIn.connectionsIn[data.input].remove(i)
			break
	emit_signal("Disconnect", data)


func InputRemoved(index:int)->void:
	if !connectionsIn.has(index):
		return
	if connectionsIn[index].empty():
		return
	var list:Array = connectionsIn[index]
	for data in list:
		var listOut:Array = data.unitOut.connectionsOut[data.output]
		for i in listOut.size():
			if listOut[i] == data:
				listOut.remove(i)
				break
	emit_signal("ConnectionsRemoved", list)

func OutputRemoved(index:int)->void:
	if !connectionsOut.has(index):
		return
	if connectionsOut[index].empty():
		return
	var list:Array = connectionsOut[index]
	for data in list:
		var listIn:Array = data.unitIn.connectionsIn[data.input]
		for i in listIn.size():
			if listIn[i] == data:
				listIn.remove(i)
				break
	emit_signal("ConnectionsRemoved", list)


#Check if connection already is existing
func ConnectionExists(data:Dictionary)->bool:
	if !connectionsOut.has(str(data.output)):
		return false
	else:
		for entry in connectionsOut[str(data.output)]:
			if entry.unitIn == data.unitIn && entry.input && data.input:
				return true
	return false

func ConnectedIn(data:Dictionary)->void:
	var entry:int = data.input
	if !connectionsIn.has(entry):
		connectionsIn[entry] = []
	connectionsIn[entry].append(data)

func ConnectedOut(data:Dictionary)->void:
	var entry:int = data.output
	if !connectionsOut.has(entry):
		connectionsOut[entry] = []
	connectionsOut[entry].append(data)
	data.unitIn.ConnectedIn(data)

func RemoveSelf()->void:
# warning-ignore:unassigned_variable
	var connections:Array
	#Inputs
	for index in inputCount:
		if !connectionsIn.has(index):
			continue
		if connectionsIn[index].empty():
			continue
		var list:Array = connectionsIn[index]
		connections.append_array(list.duplicate())
		for data in list:
			var listOut:Array = data.unitOut.connectionsOut[data.output]
			for i in listOut.size():
				if listOut[i] == data:
					listOut.remove(i)
					break
	#Outputs
	for index in outputCount:
		if !connectionsOut.has(index):
			continue
		if connectionsOut[index].empty():
			continue
		var list:Array = connectionsOut[index]
		connections.append_array(list.duplicate())
		for data in list:
			var listIn:Array = data.unitIn.connectionsIn[data.input]
			for i in listIn.size():
				if listIn[i] == data:
					listIn.remove(i)
					break
	emit_signal("ConnectionsRemoved", connections)
	queue_free()

# Chance to check if connection is valid
func ConnectionValidation(data:Dictionary)->bool:
	return !ConnectionExists(data)







