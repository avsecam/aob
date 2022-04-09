extends Control


export (String) var characterName
onready var label = $Label


func _physics_process(_delta):
	if label.text == "":
		label.text = characterName
