extends Node

enum TargetType {SINGLE, GROUP, ALL}
enum DamageType {PHYSICAL, 
	FIRE, WATER, GRASS, ELECTRIC, WIND, LIGHT, DARK, TEMPORA
}

onready var main: Node = get_node("/root/Main")
onready var player: KinematicBody = main.get_node("Overworld/Player")

const playerScene: Resource = preload("res://Scenes/Character/Player.tscn")

const enemyScenePath: String = "res://Scenes/Character/Enemy/Enemy.tscn"
const enemyFolderPath: String = "res://Scenes/Character/Enemy/"
const heroScenePath: String = "res://Scenes/Character/Hero/Hero.tscn"
const heroFolderPath: String = "res://Scenes/Character/Hero/"

const overworld: Resource = preload("res://Scenes/Overworld/Overworld.tscn")

const heroStatsPaths: Dictionary = {
	"Akune": "res://Scenes/Character/Hero/Akune.tres",
	"Elena": "res://Scenes/Character/Hero/Elena.tres",
	"Eo": "res://Scenes/Character/Hero/Eo.tres",
	"Klyne": "res://Scenes/Character/Hero/Klyne.tres"
}
