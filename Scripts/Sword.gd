extends Node2D

signal attacked
signal attacked2
signal attack_finished
signal attack_finished2

#Weapon Variables
onready var damage_area = $HandPivot/Hand/Sprite/DamageArea
onready var damage_collision = $HandPivot/Hand/Sprite/DamageArea/CollisionShape2D
onready var hand_pivot = $HandPivot
onready var hand = $HandPivot/Hand
var attack_modifier = -1
var attack_duration = 0.3 # TODO: Get from weapon
var attack_angle_range = PI / 2.0
var attack_direction = 1
onready var attack_tween = $AttackTween
onready var attack_buffer = $AttackBuffer
onready var secondary_attack_buffer = $SecondaryAttackBuffer
onready var sword_sprite = $HandPivot/Hand/Sprite

#Slash Variables
var is_projectile_firing = false

#Swipe Variables
export var radius := 8.0

func _ready():
	pass
	
func aim_weapon():
	var mouse_angle = (get_global_mouse_position() - hand_pivot.global_position).angle()
	hand_pivot.rotation = mouse_angle
	if get_parent().weapon != null:
		hand.transform = get_hand_transform(attack_modifier)
		hand_pivot.show_behind_parent = self.global_position.y < hand_pivot.global_position.y
		
func attack():
	if !attack_tween.is_active():
		emit_signal("attacked")
		if !is_projectile_firing:
			is_projectile_firing = true
		attack_tween.interpolate_property(self, "attack_modifier", \
			attack_modifier, -attack_modifier, attack_duration, \
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		attack_tween.interpolate_callback(self, attack_duration, "_on_attack_finished")
		attack_tween.start()
		
	else:
		attack_buffer.start()
		
func secondary_attack():
	if !attack_tween.is_active():
		emit_signal("attacked2")
		if !is_projectile_firing:
			is_projectile_firing = true
		attack_tween.interpolate_property(self, "attack_modifier", \
			attack_modifier, -attack_modifier, attack_duration, \
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		attack_tween.interpolate_callback(self, attack_duration, "_on_attack_finished2")
		attack_tween.start()
		
	else:
		secondary_attack_buffer.start()
		
func _on_attack_finished():
	emit_signal("attack_finished")
	attack_tween.set_active(false)
	is_projectile_firing = false
	attack_direction = -attack_direction
	damage_collision.disabled = true
	
	if attack_direction == 1:
		sword_sprite.scale.x = 1
	if attack_direction == -1:
		sword_sprite.scale.x = -1
		
	if !attack_buffer.is_stopped():
		attack_buffer.stop()
		attack()
		
func _on_attack_finished2():
	emit_signal("attack_finished2")
	attack_tween.set_active(false)
	is_projectile_firing = false
	attack_direction = -attack_direction
	damage_collision.disabled = true
	
	if attack_direction == 1:
		sword_sprite.scale.x = 1
	if attack_direction == -1:
		sword_sprite.scale.x = -1
		
	if !secondary_attack_buffer.is_stopped():
		secondary_attack_buffer.stop()
		secondary_attack()

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
	damage_collision.disabled = false

func _on_attacked2():
	pass
