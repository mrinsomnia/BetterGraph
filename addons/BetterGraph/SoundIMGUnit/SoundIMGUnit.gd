extends "../GraphUnit/GraphUnit.gd"



export var TopPath:NodePath
export var TextureButtonPath:NodePath
export var usedAudio:AudioStream = preload("res://boop_01.wav")
export var usedIMG:Texture = preload("res://icon.png")
export var showName:bool = false setget SetShowName



onready var textureButton: = get_node(TextureButtonPath)
onready var audioPlayer: = get_node("AudioStreamPlayer")

func _ready():
	textureButton.texture_normal = usedIMG
	pass

func _on_TextureButton_pressed()->void:
	audioPlayer.stream = usedAudio
	audioPlayer.play()

func SetShowName(_show = false)->void:
	if _show == false:
		
		pass
	else: 
		pass
	
