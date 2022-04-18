extends Node


var fireball: Dictionary = {
	"name": "Fireball",
	"offensive": true,
	"targetType": GameData.TargetType.SINGLE,
	"damageType": GameData.DamageType.FIRE,
	"damageMultiplier": 1,
	"resourceCost": 6
}

var magics: Dictionary = {
	# offensive
	"fireball": fireball
}
