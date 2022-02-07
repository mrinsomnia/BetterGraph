extends GraphUnit
class_name GraphSceneUnit

export var unitBellyPath:NodePath
export var sceneUnit:PackedScene = preload("res://addons/BetterGraph/SceneUnit/SceneUnit.tscn")

onready var unitBelly: = get_node(unitBellyPath)

func HoldScene()->void:
	if !is_inside_tree():
		return
		
	var inst:Control = sceneUnit.instance()
	unitBelly.add_child(inst)
	


func _ready()->void:
	var inC = inputCount
	var outC = outputCount
	inputCount = 0
	outputCount = 0
	SetInputs(inC)
	SetOutputs(outC)
	HoldScene()






