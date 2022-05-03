extends "../GraphUnit/GraphUnit.gd"



export var TopPath:NodePath
export var TextureButtonPath:NodePath
export var usedAudio:AudioStream = preload("res://boop_01.wav")
export var usedIMG:Texture = preload("res://icon.png")
export var showName:bool = false setget SetShowName


onready var topInfo: = get_node(TopPath)
onready var textureButton: = get_node(TextureButtonPath)
onready var audioPlayer: = get_node("AudioStreamPlayer")

func _ready():
	textureButton.texture_normal = usedIMG
	SetShowName(showName)

func _on_TextureButton_pressed()->void:
	audioPlayer.stream = usedAudio
	audioPlayer.play()
	SetShowName(!topInfo.visible)
	

func SetShowName(_show = false)->void:
	if _show == false:
		topInfo.visible = false
		set_state(CLEAN)
	else: 
		topInfo.visible = true
		set_state(NORMAL)

	
