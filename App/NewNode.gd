extends Button

export var unitScene:PackedScene
export var graphUnitEditorPath:NodePath

onready var graphUnitEditor:Node = get_node(graphUnitEditorPath)

func _pressed():
	if unitScene != null:
		var inst:GraphUnit = unitScene.instance()
		graphUnitEditor.AddUnit(inst)
