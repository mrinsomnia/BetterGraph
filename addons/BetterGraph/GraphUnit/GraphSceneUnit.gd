extends "GraphUnit.gd"
class_name GraphSceneUnit

export var sceneUnit:PackedScene = preload("res://addons/BetterGraph/SceneUnit/SceneUnit.tscn")


func HoldScene()->void:
	if !is_inside_tree():
		return
		
	var inst:Control = sceneUnit.instance()
	InjectScene(inst)
	


func _ready()->void:
	pass
	HoldScene()






