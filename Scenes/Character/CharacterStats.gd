extends Resource
class_name CharacterStats


export var characterName: String

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
export var evasion: int # dodge
export var critMultiplier: float
export var critChance: float
export var xp: int
export var weaknesses: Array

# Both are arrays of strings
export var magics: Array
export var techniques: Array

var currentHealth: int
var currentResource: int

var statusEffects: Array


func ready():
	currentHealth = maxHealth
	currentResource = maxResource
