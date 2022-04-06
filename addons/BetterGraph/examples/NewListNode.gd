extends Button

export var unitScene:PackedScene = preload("res://addons/BetterGraph/GraphUnit/GraphUnitNaked.tscn")
export var graphUnitEditorPath:NodePath
export var position:Vector2 = Vector2.ZERO

onready var graphUnitEditor:Node = get_node(graphUnitEditorPath)

func _pressed():
	if unitScene != null:
		graphUnitEditor.SetLeftRightLists([{"ID":44, "Name":"add! to left"}],[{"ID":4, "Name":"put! it right"}])

