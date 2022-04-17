extends Node
class_name Magics


var fireball: Dictionary = {
	"name": "Fireball",
	"offensive": true,
	"targetType": GameData.TargetType.GROUP,
	"damageType": GameData.DamageType.FIRE,
	"damageMultiplier": 1
}

var magics: Dictionary = {
	# offensive
	"fireball": fireball
}
