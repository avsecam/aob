extends Control


export var characterName: String
onready var label: Label = $Label


func _physics_process(_delta):
	if label.text == "":
		label.text = characterName
