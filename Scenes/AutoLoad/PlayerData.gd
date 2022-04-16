extends Node


const WALK_SPEED: float = 5.0
const FALL_ACCELERATION: float = 75.0
const JUMP_IMPULSE: float = 25.0
const FRICTION: float = 0.2

var location: String  # which level/stage
var position: Vector3 # which x,y,z coordinate
var rotation: Vector3

var leaderHero: Hero
var activeHeroes: Array
var activeHeroesStats: Array = [] # Array of CharacterStats
var activeHeroesStatsPaths: Array = [
	"res://Scenes/Character/Hero/Eo.tres",
	"res://Scenes/Character/Hero/Akune.tres",
	"res://Scenes/Character/Hero/Klyne.tres"
]

var inBattle: bool = false


func _ready():
	for hero in activeHeroesStatsPaths:
		add_hero(hero)
	activeHeroes = get_children()
	leaderHero = activeHeroes[0]


## Add a hero to the heroes Array.
## [code]hero[/code] is the Path to the hero CharacterStats.
func add_hero(hero: String):
	var newHeroStats: CharacterStats = load(hero)
	var newHero: Hero = load("%s%s.tscn" % [GameData.heroFolderPath, newHeroStats.characterName]).instance()
	newHeroStats.ready()
	newHero.visible = false
	activeHeroesStats.append(newHeroStats)
	add_child(newHero)


func move_hero(hero: Hero, from: Node = self, to: Node = self):
	if to == self:
		hero.visible = false
	from.remove_child(hero)
	to.add_child(hero)
