extends Node
class_name Magics


enum Target {SINGLE, GROUP, ALL}
enum DamageType {PHYSICAL, ELEMENTAL}


static func fireball(stats: CharacterStats) -> Dictionary:
	var target = Target.SINGLE
	var type = DamageType.ELEMENTAL
	var damage = stats.attackElem
	return {target: target, type: type, damage: damage}
