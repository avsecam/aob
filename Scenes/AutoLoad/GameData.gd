extends Node


onready var main: Node = get_node("/root/Main")
onready var player: KinematicBody = main.get_node("Overworld/Player")

const playerScene: Resource = preload("res://Scenes/Character/Player.tscn")

const enemyScenePath: String = "res://Scenes/Character/Enemy/Enemy.tscn"
const heroScenePath: String = "res://Scenes/Character/Hero/Hero.tscn"
const heroFolderPath: String = "res://Scenes/Character/Hero/"
