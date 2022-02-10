extends "GraphUnit.gd"
class_name GraphFlowUnit

###---Belly stuff---###
signal BellyStart
signal BellyFinish

enum UnitStyles {
	default,
	active
}

export var sceneUnit:PackedScene = preload("res://addons/BetterGraph/SceneUnit/SceneUnit.tscn")

onready var UnitStyleDefault: = load("res://addons/BetterGraph/Styles/GraphUnit.tres")
onready var UnitStyleActive: = load("res://addons/BetterGraph/Styles/GraphUnitActive.tres")
onready var UnitStyleFirst: = load("res://addons/BetterGraph/Styles/GraphUnitFirst.tres")



###---Belly stuff---###
var containedScene = null
var isRunning: = false

func _ready()->void:
	SetInputs(1)
	SetOutputs(1)
	connect("BellyStart", self, "BellyStart")
	connect("BellyFinish", self, "BellyFinish")
#	ChangeStyle(UnitStyles.default)
	
	HoldScene()
#	print(str(UnitStyles.keys()[UnitStyles.default]))
	

func InjectScene(_instance)->void:
	
	unitBelly.add_child(_instance)
	_instance.add_parent(self)
	containedScene = _instance

func BellyStart(_mirror)->void:
	if (_mirror != null && UnitBoardEditor.unitList.front() == self && UnitBoardEditor.InfoHaltFirst.pressed):
		return
	isRunning = true
	ChangeStyle(UnitStyles.active)
	if containedScene != null:
		containedScene._start()

func BellyFinish()->void:
	var teet = UnitBoardEditor.unitList.front()
	
	print("BellyFinish triggered!!!")
	isRunning = false
	ChangeStyle(UnitStyles.default)
	var connKeys = connectionsOut.keys()
	for conn in connKeys:
		var ass = connectionsOut[conn]
		for poop in ass:
			poop["unitIn"].BellyStart(self)

func HoldScene()->void:
	if !is_inside_tree():
		return
		
	var inst:Control = sceneUnit.instance()
	InjectScene(inst)

func ChangeStyle(_style)->void:
	match _style:
		UnitStyles.default:
			if UnitBoardEditor.unitList.front() == self:
				UnitStylePanel.set("custom_styles/panel", UnitStyleFirst)
			else:
				UnitStylePanel.set("custom_styles/panel", UnitStyleDefault)
		UnitStyles.active:
			UnitStylePanel.set("custom_styles/panel", UnitStyleActive)

func Bless()->void:
	ChangeStyle(UnitStyles.default)
