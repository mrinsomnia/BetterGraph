extends "GraphUnit.gd"
class_name GraphFlowUnit

###---Belly stuff---###
signal BellyStart
signal BellyFinish

enum UnitStyles {
	default,
	active
}

onready var UnitStyleDefault: = load("res://addons/BetterGraph/Styles/GraphUnit.tres")
onready var UnitStyleActive: = load("res://addons/BetterGraph/Styles/GraphUnitActive.tres")


###---Belly stuff---###
var containedScene = null
var isRunning: = false

func _ready()->void:
	SetInputs(1)
	SetOutputs(1)
	connect("BellyStart", self, "BellyStart")
	connect("BellyFinish", self, "BellyFinish")
	
	print(str(UnitStyles.keys()[UnitStyles.default]))
	

func InjectScene(_instance)->void:
	
	unitBelly.add_child(_instance)
	_instance.add_parent(self)
	containedScene = _instance

func BellyStart(_mirror)->void:
#	if _mirror != self:
	isRunning = true
	ChangeStyle(UnitStyles.active)
	if containedScene != null:
		containedScene._start()

func BellyFinish()->void:
	print("BellyFinish triggered!!!")
	isRunning = false
	ChangeStyle(UnitStyles.default)
	var connKeys = connectionsOut.keys()
	for conn in connKeys:
		var ass = connectionsOut[conn]
		for poop in ass:
			poop["unitIn"].BellyStart(self)
	
	pass

func ChangeStyle(_style):
	match _style:
		UnitStyles.default:
			UnitStylePanel.set("custom_styles/panel", UnitStyleDefault)
		UnitStyles.active:
			UnitStylePanel.set("custom_styles/panel", UnitStyleActive)
