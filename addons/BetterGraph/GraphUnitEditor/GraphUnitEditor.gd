extends Control

export var connectionDrawPath:NodePath
export var boardPath:NodePath

onready var hScroll: = $HScrollBar
onready var vScroll: = $VScrollBar
onready var board: = get_node(boardPath)
onready var connectionDraw: = get_node(connectionDrawPath)

var unitDictionary:Dictionary
var unitList:Array
var isDragged: = false
var inputSelected:Dictionary
var outputSelected:Dictionary
var connections:Dictionary
var scrollMargin:Vector2
var boardArea:Rect2
var unitSelected:GraphUnit = null


func _ready()->void:
# warning-ignore:return_value_discarded
	hScroll.connect("scrolling", self, "HScrolling")
# warning-ignore:return_value_discarded
	vScroll.connect("scrolling", self, "VScrolling")
	scrollMargin = Vector2(vScroll.rect_size.x, hScroll.rect_size.y)
	boardArea.size = rect_size - scrollMargin
	UpdateScrollBars()

func _gui_input(event:InputEvent)->void:
	if event is InputEventMouseButton:
		if event.button_index == 3:
			if event.pressed && !isDragged:
				isDragged = true
			if !event.pressed && isDragged:
				isDragged = false
	elif event is InputEventMouseMotion && isDragged:
		hScroll.value -= event.relative.x
		vScroll.value -= event.relative.y
		HScrolling()
		VScrolling()

func UpdateScrollBars()->void:
	hScroll.max_value = boardArea.size.x
	vScroll.max_value = boardArea.size.y
	hScroll.page = rect_size.x - scrollMargin.x
	vScroll.page = rect_size.y - scrollMargin.y
	#hScroll.value = -boardArea.position.x
	#vScroll.value = -boardArea.position.y

func HScrolling()->void:
	board.rect_position.x = (hScroll.value -boardArea.position.x)
	print(board.rect_position)

func VScrolling()->void:
	board.rect_position.y = (vScroll.value -boardArea.position.y)

func AddUnit(unit:GraphUnit, pos:Vector2 = Vector2.ZERO)->void:
	board.add_child(unit)
	unit.rect_position = pos + Vector2(hScroll.value, vScroll.value)
	unitDictionary[unit.name] = unit
	unitList.append(unit)
	unit.connect("UnitSelected", self, "UnitSelected")
	
# warning-ignore:return_value_discarded
	unit.connect("tree_exited", self, "RemoveUnit", [unit])
# warning-ignore:return_value_discarded
	unit.connect("UnitChanged", self, "UnitChanged")
# warning-ignore:return_value_discarded
	unit.connect("InputPressed", self, "InputPressed")
# warning-ignore:return_value_discarded
	unit.connect("OutputPressed", self, "OutputPressed")
# warning-ignore:return_value_discarded
	unit.connect("Disconnect", self, "Disconnect")
# warning-ignore:return_value_discarded
	unit.connect("ConnectionsRemoved", self, "ConnectionsRemoved")
# warning-ignore:return_value_discarded
	unit.connect("DrawConnections", connectionDraw, "update")

func UpdateEditor()->void:
	UpdateScrollBars()
	HScrolling()
	VScrolling()
	connectionDraw.update()

func RemoveUnit(unit:GraphUnit)->void:
# warning-ignore:return_value_discarded
	unitDictionary.erase(unit.name)
	unitList.clear()
	for k in unitDictionary.keys():
		unitList.append(unitDictionary[k])
	#TO-DO: check if unit has active connections

func MoveUnits(offset:Vector2)->void:
	for unit in unitList:
		unit.rect_position += offset

func UnitSelected(newUnit:GraphUnit)->void:
	if (unitSelected != null):
		unitSelected.state = GraphUnit.NORMAL
	unitSelected = newUnit
	unitSelected.state = GraphUnit.SELECTED

func UnitChanged(unit:GraphUnit)->void:
	### OPTIMIZE SHRINK & EXTEND
	### NOW ONLY EXTENDS
	var pos: = unit.rect_global_position
	var pos2: = unit.rect_size + unit.rect_position
	var boardPos2: = boardArea.size - boardArea.position
	print(pos, ' ', pos2)
	
	if pos.x < boardArea.position.x:
		boardArea.size.x += boardArea.position.x - pos.x
		boardArea.position.x = pos.x
	
	if pos.y < boardArea.position.y:
		boardArea.size.y += boardArea.position.y - pos.y
		boardArea.position.y = pos.y
	
	if pos2.x > boardPos2.x:
		boardArea.size.x += pos2.x - boardPos2.x
	
	if pos2.y > boardPos2.y:
		boardArea.size.y += pos2.y - boardPos2.y
	
	
	var offset: = Vector2.ZERO
	var move: = false
	
#	if move:
#		MoveUnits(offset)
	
	UpdateEditor()

func InputPressed(unit:GraphUnit, input:int)->void:
	if outputSelected.empty():
		inputSelected["unit"] = unit
		inputSelected["input"] = input
	else:
		if outputSelected.unit == unit:
			return
		if EstablishConnection(outputSelected.unit , unit, outputSelected.output , input):
			outputSelected.clear()

func OutputPressed(unit:GraphUnit, output:int)->void:
	if inputSelected.empty():
		outputSelected["unit"] = unit
		outputSelected["output"] = output
	else:
		if inputSelected.unit == unit:
			return
		if EstablishConnection(unit , inputSelected.unit, output ,inputSelected.input):
			inputSelected.clear()

func EstablishConnection(unitOut:GraphUnit, unitIn:GraphUnit, output:int, input:int)->bool:
	var data:Dictionary = {
		unitOut = unitOut,
		output = output,
		unitIn = unitIn,
		input = input
	}
	if !unitOut.ConnectionValidation(data):
		return false
	unitOut.ConnectedOut(data)
	if !connections.has(unitOut):
		connections[unitOut] = []
	connections[unitOut].append(data)
	connectionDraw.update()
	return true

func Disconnect(data:Dictionary)->void:
	for i in connections[data.unitOut].size():
		if connections[data.unitOut][i] == data:
			connections[data.unitOut].remove(i)
			break
	connectionDraw.update()

func ConnectionsRemoved(list:Array)->void:
	for data in list:
		for i in connections[data.unitOut].size():
			if connections[data.unitOut][i] == data:
				connections[data.unitOut].remove(i)
				break
	connectionDraw.update()


