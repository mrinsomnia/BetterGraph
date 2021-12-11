extends Button

export var unitScene:PackedScene
export var graphUnitEditorPath:NodePath
export var position:Vector2 = Vector2.ZERO

onready var graphUnitEditor:Node = get_node(graphUnitEditorPath)

func _pressed():
	if unitScene != null:
		var inst:GraphUnit = unitScene.instance()
		graphUnitEditor.AddUnit(inst, position)
