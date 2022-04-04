extends Control

export var connectionDrawPath:NodePath
export var unitScene:PackedScene = preload("res://addons/BetterGraph/GraphUnit/GraphUnitNaked.tscn")

onready var hScroll: = $HScrollBar
onready var vScroll: = $VScrollBar
onready var board: = $Board
onready var connectionDraw: = get_node(connectionDrawPath)

var unitDictionary:Dictionary
var unitList:Array
var isDragged: = false
var inputSelected:Dictionary
var outputSelected:Dictionary
var connections:Dictionary
var scrollMargin:Vector2

var draggedUnit:GraphUnit = null
var pos_mouse:Vector2 = Vector2.ZERO
var leftList:Array = []
var rightList:Array = []


func _ready()->void:
# warning-ignore:return_value_discarded
	hScroll.connect("scrolling", self, "HScrolling")
# warning-ignore:return_value_discarded
	vScroll.connect("scrolling", self, "VScrolling")
	scrollMargin = Vector2(vScroll.rect_size.x, hScroll.rect_size.y)
	board.rect_size = rect_size - scrollMargin
	UpdateScrollBars()
	AddToLeft(2, "RealValue")
	AddToLeft(3, "ARealValue")

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
	hScroll.max_value = board.rect_size.x + scrollMargin.x
	hScroll.value = -board.rect_position.x
	hScroll.page = rect_size.x
	vScroll.max_value = board.rect_size.y + scrollMargin.y
	vScroll.value = -board.rect_position.y
	vScroll.page = rect_size.y

func HScrolling()->void:
	board.rect_position.x = -hScroll.value

func VScrolling()->void:
	board.rect_position.y = -vScroll.value

func AddUnit(unit:GraphUnit, pos:Vector2 = Vector2.ZERO)->void:
	board.add_child(unit)
	unit.SetBoard(self)
	unit.rect_position = pos + Vector2(hScroll.value, vScroll.value)
	unitDictionary[unit.name] = unit
	unitList.append(unit)
	
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
	unit.connect("UnitDragged", self, "UnitDragged")
# warning-ignore:return_value_discarded
	unit.connect("DrawConnections", connectionDraw, "update")
	
	unit.Bless()
	

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

func UnitChanged(unit:GraphUnit, pos:Vector2, size:Vector2)->void:
	### OPTIMIZE SHRINK & EXTEND
	### NOW ONLY EXTENDS
	if pos.x + size.x > board.rect_size.x:
		board.rect_size.x = pos.x + size.x
	
	if pos.y + size.y > board.rect_size.y:
		board.rect_size.y = pos.y + size.y
	
	var offset: = Vector2.ZERO
	var move: = false
	if pos.x < 0.0:
		board.rect_size.x += -pos.x
		offset.x = -pos.x
		move = true
	
	if pos.y < 0.0:
		board.rect_size.y += -pos.y
		offset.y = -pos.y
		move = true
	
	if move:
		MoveUnits(offset)
	
	if board.rect_size > rect_size - scrollMargin:
		var limits = rect_size - scrollMargin
		for unit in unitList:
			var unitLimit:Vector2 = unit.rect_position + unit.rect_size
			if unitLimit.x > limits.x:
				limits.x = unitLimit.x
			if unitLimit.y > limits.y:
				limits.y = unitLimit.y
		board.rect_size = limits
	
	UpdateScrollBars()
	connectionDraw.update()
	HScrolling()
	VScrolling()

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

func _on_StartFirst_pressed()->void:
	unitList.front().BellyStart(null)

func AddToLeft(_id:int, _name:String)->void:
	if _id < 0 || !_name.is_valid_identifier():
		print("ERR - ID or Name of GraphUnitNaked is not valid!")
		return
	# iterate through _list and add as Units
	# element = ID & Name = GraphUnitNaked.tscn
	var _unit = unitScene.instance()
	_unit.unitID = _id
	_unit.unitName = _name
	_unit.inputCount = 1
	_unit.outputCount = 1
	
	self.AddUnit(_unit, Vector2(100,100*(leftList.size()+1)))
	leftList.append(_unit)

func UnitDragged(unit:GraphUnit, _pos:Vector2)->void:
	if unit == null:
		# iterate through Units to check if released on a node for a new Connection
		for _unit in unitList:
			if _unit.get_global_rect().has_point(draggedUnit.rect_global_position + pos_mouse):
				InputPressed(_unit, 0)
		
		draggedUnit = null
		pos_mouse = Vector2.ZERO
		
	else:
		draggedUnit = unit
		pos_mouse = _pos
	
	connectionDraw.update()

