extends Control

onready var hScroll: = $HScrollBar
onready var vScroll: = $VScrollBar
onready var board: = $Board

var unitList:Dictionary

func _ready()->void:
# warning-ignore:return_value_discarded
	hScroll.connect("scrolling", self, "HScrolling")
# warning-ignore:return_value_discarded
	vScroll.connect("scrolling", self, "VScrolling")
	UpdateScrollBars()

func UpdateScrollBars()->void:
	#yield(get_tree(), "idle_frame")
	hScroll.max_value = board.rect_size.x
	hScroll.value = -board.rect_position.x
	hScroll.page = rect_size.x
	vScroll.max_value = board.rect_size.y
	vScroll.value = -board.rect_position.y
	vScroll.page = rect_size.y

func HScrolling()->void:
	board.rect_position.x = -hScroll.value

func VScrolling()->void:
	board.rect_position.y = -vScroll.value

func AddUnit(unit:Node)->void:
	unitList[unit.name] = unit

func RemoveUnit(unit:Node)->void:
	unitList.erase(unit.name)

func UnitChanged(pos:Vector2, size:Vector2)->void:
	print(pos, ' ', size)
