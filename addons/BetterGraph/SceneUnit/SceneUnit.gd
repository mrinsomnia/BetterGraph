extends PanelContainer


export(PackedScene) var scene_file
var my_parent:Node = null
var my_child:Node = null

func _ready()->void:
	if scene_file != null:
		# adding a preset of Scene to be contained in the belly
		var _scene = scene_file.instance()
		self.add_child(_scene)
		my_child = _scene
		my_child.add_parent(self)
	

func add_parent(_papa)->void:
	my_parent = _papa

func _start()->void:
	# should trigger start of the contained Scene
	my_child._start()

func _finish()->void:
	my_parent.emit_signal("BellyFinish")
