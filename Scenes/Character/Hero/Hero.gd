extends "res://Scenes/Character/Character.gd"
class_name Hero


func _ready():
	characterStats = load(GameData.heroStatsPaths[name])
	characterStats.ready()
