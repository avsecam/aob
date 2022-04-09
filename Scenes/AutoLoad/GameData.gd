extends Node


onready var main = get_node("/root/Main")
onready var player = main.get_node("Overworld/Player")

const playerScene = preload("res://Scenes/Character/Player.tscn")
