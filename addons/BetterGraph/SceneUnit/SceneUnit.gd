extends PanelContainer


export(PackedScene) var scene_file


func _ready()->void:
	if scene_file != null:
		var _scene = scene_file.instance()
		self.add_child(_scene)
	
