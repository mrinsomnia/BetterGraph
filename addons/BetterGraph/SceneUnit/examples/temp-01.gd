extends PanelContainer
# this is an example Scene
# a stepping stone, so to say


onready var AudioStreamPlayer = $AudioStreamPlayer

var my_parent:Node = null

func _ready()->void:
#	AudioStreamPlayer.connect("finished", self, "_finish()")
	pass
	
func add_parent(_papa)->void:
	my_parent = _papa

func _start()->void:
	AudioStreamPlayer.play()

func _on_AudioStreamPlayer_finished():
#	print("mi papa: ",str(my_parent))
	my_parent._finish()


func _on_Button_pressed():
	AudioStreamPlayer.play()
