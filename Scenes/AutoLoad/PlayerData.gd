extends Node


const WALK_SPEED: float = 5.0
const FALL_ACCELERATION: float = 75.0
const JUMP_IMPULSE: float = 25.0
const FRICTION: float = 0.2

var location: String  # which level/stage
var position: Vector3 # which x,y,z coordinate
var rotation: Vector3

var leaderHero: CharacterStats
var activeHeroes: Array = [] # Array of CharacterStats
var heroesTest = [
	"res://Scenes/Character/Hero/Eo.tres",
	"res://Scenes/Character/Hero/Akune.tres",
	"res://Scenes/Character/Hero/Klyne.tres",
	"res://Scenes/Character/Hero/Elena.tres"
]

var inBattle: bool = false


func _ready():
	for hero in heroesTest:
		add_hero(hero)
	leaderHero = activeHeroes[0]


## Add a hero to the heroes Array.
## [code]hero[/code] is the Path to the hero CharacterStats.
func add_hero(hero: String):
	var newHero: CharacterStats = load(hero)
	newHero.ready()
	activeHeroes.append(newHero)
