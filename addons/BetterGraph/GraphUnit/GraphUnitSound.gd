extends "GraphUnitNaked.gd"
class_name GraphUnitSound


export var Path_AudioPlayer:NodePath

onready var AudioPlayer:Node = get_node(Path_AudioPlayer)

var PlayableSoundFile

func SetContent(_file)->void:
	AudioPlayer = get_node(Path_AudioPlayer)
	PlayableSoundFile = _file
	AudioPlayer.stream = PlayableSoundFile
	

func _on_PlayBelly_pressed():
	AudioPlayer.play()
