extends Character
class_name Player

signal attacked
signal attacked2
signal attack_finished
signal attack_finished2
signal dash_finished

export(PackedScene) var Running_Steps
var last_step = 0

##Character Info
onready var hand_pivot = $HandPivot
onready var hand = $HandPivot/Hand

#TWEENS
onready var dash_tween = $Tweens/DashTween
onready var attack_tween = $Tweens/AttackTween

#Particles
onready var particlePosition = $ParticlePoint
onready var particleScene = preload("res://Running_Steps.tscn")

#Movement
var dash_velocity = 10 * 35
var move_input : Vector2
var facing := Vector2.RIGHT
var dash_duration = 0.3

#Attack/Weapon
onready var attack_buffer = $AttackBuffer
var weapon = null
var attack_modifier = -1
var attack_duration = 0.3 # TODO: Get from weapon
var attack_angle_range = PI / 2.0
var attack_direction = 1

var is_projectile_firing = false

#Animations
onready var animationPlayer = $AnimationPlayer

func _ready():
	set_weapon(preload("res://Weapon.tscn").instance())

func set_weapon(weapon):
	if self.weapon != null:
		self.weapon.queue_free()
	
	if weapon != null:
		hand.add_child(weapon)
		self.weapon = weapon
		weapon.init(self)
#		hitbox.add_exception(weapon.damage_area)
		weapon.damage_area.collision_layer = CollisionLayers.ENEMY_HAZARD
	
	connect("attacked", weapon, "_on_attacked")
	connect("attack_finished", weapon, "_on_attack_finished")
	connect("attacked2", weapon, "_on_attacked2")
	connect("attacked_finished2", weapon, "on_attacked_finished2")

func _input(event):
	if event.is_action_pressed("attack"):
		attack()
	elif event.is_action_pressed("secondary_attack"):
		secondary_attack()

func aim_weapon():
	var mouse_angle = (get_global_mouse_position() - hand_pivot.global_position).angle()
	hand_pivot.rotation = mouse_angle
	if weapon != null:
		hand.transform = weapon.get_hand_transform(attack_modifier)
		hand_pivot.show_behind_parent = weapon.global_position.y < hand_pivot.global_position.y
		
func attack():
	if !attack_tween.is_active() && state_machine.can_attack():
		emit_signal("attacked")
		attack_tween.interpolate_property(self, "attack_modifier", \
			attack_modifier, -attack_modifier, attack_duration, \
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		attack_tween.interpolate_callback(self, attack_duration, "_on_attack_finished")
		attack_tween.start()
	else:
		attack_buffer.start()
		
func secondary_attack():
	if !attack_tween.is_active() && state_machine.can_attack() && !is_projectile_firing:
		is_projectile_firing = true
		emit_signal("attacked2")
		attack_tween.interpolate_property(self, "attack_modifier", \
			attack_modifier, -attack_modifier, attack_duration, \
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		attack_tween.interpolate_callback(self, attack_duration, "_on_attack_finished2")
		attack_tween.start()
		
		var swipe_instance = load("res://Swipe.tscn").instance()
		swipe_instance.shoot(get_global_mouse_position(), weapon.global_position)
		owner.add_child(swipe_instance)
		
	else:
		attack_buffer.start()
		
func _on_attack_finished():
	emit_signal("attack_finished")
	weapon.scale
	attack_tween.set_active(false)
	attack_direction = -attack_direction
	
	if attack_direction == 1:
		weapon.scale.y = 1
	if attack_direction == -1:
		weapon.scale.y = -1
		
	if !attack_buffer.is_stopped():
		attack_buffer.stop()
		attack()
		
func _on_attack_finished2():
	emit_signal("attack_finished2")
	weapon.scale
	attack_tween.set_active(false)
	is_projectile_firing = false
	attack_direction = -attack_direction
	
	if attack_direction == 1:
		weapon.scale.y = 1
	if attack_direction == -1:
		weapon.scale.y = -1
		
	if !attack_buffer.is_stopped():
		attack_buffer.stop()
		secondary_attack()

func _update_move_input():
	move_input.x = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	move_input.y = -int(Input.is_action_pressed("move_up")) + int(Input.is_action_pressed("move_down"))
	move_input = move_input.normalized()
	if move_input == Vector2.ZERO:
		animationPlayer.play("idle")
	if move_input != Vector2.ZERO:
		
		##THIS SECTION CONTROLS PLAYER FOOTSTEP PARTICLES
		var running_step = Running_Steps.instance()
		if body.frame == 3 || body.frame == 5:
			running_step.global_position = Vector2(global_position.x - 4, global_position.y + 8)
			if move_input < Vector2.ZERO:
				running_step.global_position = Vector2(global_position.x + 4, global_position.y + 8)
			running_step.emitting = true
		get_parent().add_child(running_step)
		
		animationPlayer.play("run")
		

func _update_facing():
	if move_input != Vector2.ZERO:
		facing = move_input
	var mouse = get_global_mouse_position() - hand_pivot.global_position
	body.scale.x = -1 if mouse.x < 0 else 1
	hand_pivot.scale.y = body.scale.x

func apply_velocity():
	var desired_velocity = move_input * move_speed_units * 16
	velocity = velocity.linear_interpolate(desired_velocity, get_move_weight())

func apply_dash_velocity():
	velocity = velocity.linear_interpolate(Vector2.ZERO, 0.005)
	
func dash():
	weapon.hide()
	hand.hide()
	if move_input < Vector2.ZERO:
		body.scale.x = -1
		hand_pivot.scale.y = body.scale.x
		animationPlayer.play("dash")
		
	else:
		animationPlayer.play("dash")
	
	dash_tween.interpolate_property(body, "position:y", 0, \
			dash_duration / 2.0, Tween.TRANS_SINE, Tween.EASE_OUT)
	dash_tween.interpolate_property(body, "position:y", 0, \
			dash_duration / 2.0, Tween.TRANS_SINE, Tween.EASE_IN, dash_duration / 2.0)
	dash_tween.interpolate_callback(self, dash_duration, "_on_dash_finished")
	dash_tween.start()
	
	##hitbox_collision.disabled = true
	velocity = facing * dash_velocity

func _on_dash_finished():
	$DashTimer.stop()
	weapon.show()
	hand.show()
	emit_signal("dash_finished")
	##hitbox_collision.disabled = false


func _on_DashTimer_timeout():
		$DashTimer.start()
		var this_ghost = preload("res://Ghost.tscn").instance()
		#give the ghost a parent
		this_ghost.position = position
		this_ghost.texture = $Body.texture
		this_ghost.vframes = $Body.vframes
		this_ghost.hframes = $Body.hframes
		this_ghost.frame = $Body.frame
		if move_input < Vector2.ZERO:
			this_ghost.scale.x = -1
			hand_pivot.scale.y = this_ghost.scale.x
		get_parent().add_child(this_ghost)
		
