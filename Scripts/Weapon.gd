extends Node2D

signal attacked
signal attacked2
signal attack_finished
signal attacked_finished2
signal dash_finished

#Weapon Variables
onready var damage_area = $DamageArea
onready var damage_collision = $DamageArea/CollisionShape2D

#Slash Variables
onready var slash_collision = $DamageArea/CollisionPolygon2D
onready var Ani_Slash = $Slash/AnimationPlayer
onready var SlashSprite = $Slash

export var radius := 8.0

func init(attacker):
	damage_area.attacker = attacker

func get_hand_transform(attack_modifier) -> Transform2D:
#	return get_stab_transform(attack_modifier)
	return get_swing_transform(attack_modifier)

func get_stab_transform(attack_modifier, stab_range = 32, offset = 8) -> Transform2D:
	var pos = (1 - abs(attack_modifier)) * stab_range + offset
	return Transform2D(0, Vector2.RIGHT * pos)

func get_swing_transform(attack_modifier) -> Transform2D:
	var attack_angle = PI / 2.0 * attack_modifier
	var pos = polar2cartesian(radius, attack_angle)
	var hand_angle = PI * attack_modifier
	return Transform2D(hand_angle, pos)

func _on_attacked():
	SlashSprite.show()
	Ani_Slash.play("Slash")
	##CHECK COLLISION ON SLASH LATER!!!
	damage_collision.disabled = false
	slash_collision.disabled = false # enable

func _on_attack_finished():
	SlashSprite.hide()
	damage_collision.disabled = true
	slash_collision.disabled = true # disable
	
func _on_attacked2():
	pass
	
func _on_attack_finished2():
	pass
