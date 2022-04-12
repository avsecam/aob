extends Resource
class_name CharacterStats


signal attack(target, damage) # damage = attackPhys with crit calculation
signal defend()
signal magic(spell) # spell may be a function (FuncRef)
signal technique(tech) # same as above
signal item(item) # same as above
signal flee()

export (String) var characterName

# stats
export var level: int
export var maxHealth: int
export var maxResource: int
export var attackPhys: int
export var attackElem: int
export var defensePhys: int
export var defenseElem: int
export var resilience: int # resilience to debuffs
export var speed: int # dictates turn order
export var critMultiplier: float
export var critChance: float

var currentHealth: int
var currentResource: int

var statusEffects: Array = []

func ready():
	currentHealth = maxHealth
	currentResource = maxResource

# attack magic technique item defend flee
