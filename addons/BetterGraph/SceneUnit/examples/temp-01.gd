extends PanelContainer
# this is an example Scene
# a stepping stone, so to say


onready var AudioStreamPlayer = $AudioStreamPlayer



func _on_Button_pressed():
	AudioStreamPlayer.play()
