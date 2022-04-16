extends "res://Scenes/Character/Character.gd"
class_name Enemy


func _ready():
	characterStats = load("%s%s.tres" % [GameData.enemyFolderPath, name])
	characterStats.ready()
