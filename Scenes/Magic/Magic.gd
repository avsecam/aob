extends Node
class_name Magics


var fireball: Dictionary = {
	"targetType": GameData.TargetType.SINGLE,
	"damageType": GameData.DamageType.FIRE,
	"damageMultiplier": 1
}

var magics: Dictionary = {
	# offensive
	"fireball": fireball
}
