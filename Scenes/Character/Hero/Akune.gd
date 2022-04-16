extends "res://Scenes/Character/Hero/Hero.gd"


func _ready():
	characterStats.magics.append("fireball")
	print(characterStats.magics)
